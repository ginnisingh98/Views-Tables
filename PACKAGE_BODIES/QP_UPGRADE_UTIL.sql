--------------------------------------------------------
--  DDL for Package Body QP_UPGRADE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_UPGRADE_UTIL" AS
/* $Header: QPXUPGRB.pls 120.0 2005/06/02 00:40:33 appldev noship $ */
--===========================================================================
--     This script defines a procedure qp_update_upgrade to update the default type
--     This script defines a procedure qp_update_upgrade to update the default type
--     default value, required flag, sequence number, enabled flag and displyed flag
--     columns in the flexfiled table. These columns were not upgraded in the express--     upgrade.
--     default value, required flag, sequence number, enabled flag and displyed flag
--     columns in the flexfiled table. These columns were not upgraded in the express--     upgrade.

--===========================================================================


FUNCTION check_context_existance(  p_application_id             IN fnd_application.application_id%TYPE,
	                              p_descriptive_flexfield_name IN VARCHAR2,
					          p_descr_flex_context_code    IN VARCHAR2)
RETURN BOOLEAN

IS

 dummy NUMBER(1);
 x_context_exists BOOLEAN := TRUE;

BEGIN
 SELECT NULL INTO dummy
 FROM fnd_descr_flex_contexts
 WHERE application_id = p_application_id
 AND descriptive_flexfield_name = p_descriptive_flexfield_name
 AND descriptive_flex_context_code = p_descr_flex_context_code;

 --dbms_output.put_line ('Context Check Successful');
 return x_context_exists;

EXCEPTION
 WHEN no_data_found THEN
  x_context_exists := FALSE;
  return x_context_exists;
 WHEN OTHERS THEN
  NULL;
  --dbms_output.put_line ('Error in Context Check');
END;

FUNCTION check_segment_existance( p_application_id NUMBER,
						    p_context_code VARCHAR2,
					         p_flexfield_name VARCHAR2,
					         p_application_column_name VARCHAR2)
RETURN BOOLEAN
IS

 dummy NUMBER(1);
 x_seg_exists BOOLEAN := TRUE;

BEGIN
 select NULL INTO dummy
 from FND_DESCR_FLEX_COLUMN_USAGES
 where APPLICATION_ID = p_application_id
 and DESCRIPTIVE_FLEX_CONTEXT_CODE = p_context_code
 and DESCRIPTIVE_FLEXFIELD_NAME = p_flexfield_name
 and APPLICATION_COLUMN_NAME = p_application_column_name;

 --dbms_output.put_line ('Segment Check Successful');
 return x_seg_exists ;

EXCEPTION
 WHEN no_data_found THEN
  x_seg_exists := FALSE;
  return x_seg_exists;
 WHEN OTHERS THEN
  NULL;
  --dbms_output.put_line ('Error in Segment Check');
END;

FUNCTION check_segment_name_existance( p_application_id NUMBER,
						         p_context_code VARCHAR2,
					              p_flexfield_name VARCHAR2,
					              p_segment_name VARCHAR2)
RETURN BOOLEAN
IS

 dummy NUMBER(1);
 x_seg_exists BOOLEAN := TRUE;

BEGIN
 select NULL INTO dummy
 from FND_DESCR_FLEX_COLUMN_USAGES
 where APPLICATION_ID = p_application_id
 and DESCRIPTIVE_FLEX_CONTEXT_CODE = p_context_code
 and DESCRIPTIVE_FLEXFIELD_NAME = p_flexfield_name
 and END_USER_COLUMN_NAME = p_segment_name;

 --dbms_output.put_line ('Segment Name Check Successful');
 return x_seg_exists ;

EXCEPTION
 WHEN no_data_found THEN
  x_seg_exists := FALSE;
  return x_seg_exists;
 WHEN OTHERS THEN
  NULL;
  --dbms_output.put_line ('Error in Segment Name Check');
END;

PROCEDURE QP_UPDATE_UPGRADE(    P_PRODUCT            IN VARCHAR2
						, P_NEW_PRODUCT        IN VARCHAR2
						, P_FLEXFIELD_NAME     IN VARCHAR2
						, P_NEW_FLEXFIELD_NAME IN VARCHAR2)
IS
	   P_FLEXFIELD FND_DFLEX.DFLEX_R;
	   P_FLEXINFO  FND_DFLEX.DFLEX_DR;
	   L_CONTEXTS FND_DFLEX.CONTEXTS_DR;
	   GDE_CONTEXTS FND_DFLEX.CONTEXTS_DR;
	   L_SEGMENTS FND_DFLEX.SEGMENTS_DR;
	   GDE_SEGMENTS FND_DFLEX.SEGMENTS_DR;
	   NEW_GDE_SEGMENTS FND_DFLEX.SEGMENTS_DR;
	   L_REQUIRED VARCHAR2(5);
	   L_ENABLED VARCHAR2(5);
	   L_DISPLAYED VARCHAR2(5);

	   L_VALUE_SET_ID NUMBER := 0;
	   L_VALUE_SET VARCHAR2(100) := NULL;
	   L_SEGMENT_COUNT NUMBER;
	   p_segment_name  VARCHAR2(240);
	   NEW_GDE_CONTEXT_CODE CONSTANT VARCHAR2(30) := 'Upgrade Context';
	   OLD_GDE_CONTEXT_CODE CONSTANT VARCHAR2(30) := 'Global Data Elements';
	   G_QP_ATTR_DEFNS_PRICING CONSTANT VARCHAR2(30) := 'QP_ATTR_DEFNS_PRICING';
	   QP_APPLICATION_ID    CONSTANT fnd_application.application_id%TYPE := 661;
	   p_context_name  VARCHAR2(240);
	   p_application_column_name  VARCHAR2(240);
	   p_application_id	VARCHAR2(30);
BEGIN

      FND_FLEX_DSC_API.SET_SESSION_MODE('customer_data');

/* vivek

      FND_PROFILE.PUT('RESP_APPL_ID','0');
      FND_PROFILE.PUT('RESP_ID','20419');
      FND_PROFILE.PUT('USER_ID','1001');
     -- Delete all the segments under the New Global Data Elements Context(if any)

	 --dbms_output.put_line ('Before even starting the process');
  IF ( FND_FLEX_DSC_API.FLEXFIELD_EXISTS( P_NEW_PRODUCT,
								  P_NEW_FLEXFIELD_NAME )) THEN
	 --dbms_output.put_line ('Entered the Processing');
   IF (P_NEW_FLEXFIELD_NAME = G_QP_ATTR_DEFNS_PRICING) THEN
     -- Get the New Global Data Elements Context and Its Segments
	FND_DFLEX.GET_FLEXFIELD( P_NEW_PRODUCT
					, P_NEW_FLEXFIELD_NAME
					, P_FLEXFIELD
					, P_FLEXINFO );

     -- Get all contexts for the flexfield
	FND_DFLEX.GET_CONTEXTS( P_FLEXFIELD, L_CONTEXTS );

	-- Get the Context Code for New Global Data Elements Context (if any)
	FOR I IN 1..L_CONTEXTS.NCONTEXTS LOOP
	 --dbms_output.put_line ('Found the Old GDE Context');
	 IF (L_CONTEXTS.CONTEXT_CODE(I) = OLD_GDE_CONTEXT_CODE) THEN
       FND_DFLEX.GET_SEGMENTS ( FND_DFLEX.MAKE_CONTEXT( P_FLEXFIELD , OLD_GDE_CONTEXT_CODE)
				          ,NEW_GDE_SEGMENTS
				          , FALSE ) ;
	 END IF;
	 EXIT;
     END LOOP;

    IF (NEW_GDE_SEGMENTS.NSEGMENTS > 0) THEN
	--dbms_output.put_line('New GDE has segments');
     FOR I IN 1..NEW_GDE_SEGMENTS.NSEGMENTS LOOP
	 --dbms_output.put_line('Trying to delete segments under old context');
      FND_FLEX_DSC_API.DELETE_SEGMENT( P_NEW_PRODUCT
							 ,P_NEW_FLEXFIELD_NAME
							 ,OLD_GDE_CONTEXT_CODE -- Global Data Elements
							 ,NEW_GDE_SEGMENTS.SEGMENT_NAME(I));
     END LOOP;
    ELSE
	NULL;
	--dbms_output.put_line('New GDE has no segments');
    END IF; -- NEW_GDE_SEGMENTS.NSEGMENTS > 0
   END IF;
  END IF;
vivek */
	--dbms_output.put_line('Starting the actual Migration');
    -- Now start the migration of contexts and segments
    FND_DFLEX.GET_FLEXFIELD(
					  P_PRODUCT
					, P_FLEXFIELD_NAME
					, P_FLEXFIELD
					, P_FLEXINFO );

    FND_DFLEX.GET_CONTEXTS( P_FLEXFIELD, L_CONTEXTS );

    -- Store all the old contexts
    GDE_CONTEXTS := L_CONTEXTS;

  -- Check To See If New Flex Structure Exists
  IF ( FND_FLEX_DSC_API.FLEXFIELD_EXISTS( P_NEW_PRODUCT,
								  P_NEW_FLEXFIELD_NAME )) THEN
     FOR I IN 1..L_CONTEXTS.NCONTEXTS LOOP
	 --dbms_output.put_line ( ' Global Code : ' || L_CONTEXTS.CONTEXT_CODE(I));
	 IF (L_CONTEXTS.CONTEXT_CODE(I) = OLD_GDE_CONTEXT_CODE AND P_NEW_FLEXFIELD_NAME = G_QP_ATTR_DEFNS_PRICING) THEN
	     --dbms_output.put_line('There are contexts for migration');
/* vivek IF (check_context_existance(QP_APPLICATION_ID,P_NEW_FLEXFIELD_NAME,NEW_GDE_CONTEXT_CODE) = FALSE) THEN
		 --dbms_output.put_line ('Creating the Upgrade Context');
            FND_FLEX_DSC_API.CREATE_CONTEXT ( P_NEW_PRODUCT
								   , P_NEW_FLEXFIELD_NAME
								   , NEW_GDE_CONTEXT_CODE
								   , NEW_GDE_CONTEXT_CODE
								   , NEW_GDE_CONTEXT_CODE
								   , 'Y'
								   , 'N') ;
		 --dbms_output.put_line ('Created the Upgrade Context');
		ELSE
		 NULL;
		 --dbms_output.put_line ('Upgrade Context Already Exists');
		END IF;
	     FND_FLEX_DSC_API.ENABLE_CONTEXT (P_NEW_PRODUCT
								,  P_NEW_FLEXFIELD_NAME
								,  NEW_GDE_CONTEXT_CODE
								,  TRUE );

		FND_FLEX_DSC_API.ENABLE_COLUMNS( P_NEW_PRODUCT
								,  P_NEW_FLEXFIELD_NAME
								, 'ATTRIBUTE[0-9]+');

 vivek */
		FND_DFLEX.GET_SEGMENTS ( FND_DFLEX.MAKE_CONTEXT( P_FLEXFIELD , L_CONTEXTS.CONTEXT_CODE(I))
					          ,L_SEGMENTS
					          , FALSE ) ;


	     -- Store all the old global data elements' segments
		GDE_SEGMENTS := L_SEGMENTS;

          --dbms_output.put_line ( 'Old GDE Segments Count##: ' || nvl(GDE_SEGMENTS.NSEGMENTS,0));

		FOR J IN 1..L_SEGMENTS.NSEGMENTS LOOP
/* vivek 	   L_VALUE_SET_ID := L_SEGMENTS.VALUE_SET(J);
		 BEGIN
		  IF L_VALUE_SET_ID <> 0 THEN
			SELECT FLEX_VALUE_SET_NAME INTO
			L_VALUE_SET
			FROM FND_FLEX_VALUE_SETS
			WHERE FLEX_VALUE_SET_ID = L_VALUE_SET_ID;
		  ELSE
			L_VALUE_SET := NULL;
		  END IF;
		 EXCEPTION
			WHEN NO_DATA_FOUND THEN
			   L_VALUE_SET := NULL;
			WHEN TOO_MANY_ROWS THEN
			  NULL;
		 END;
vivek */
		 IF (L_SEGMENTS.IS_REQUIRED(J) ) THEN
			L_REQUIRED := 'Y';
	      ELSE
			L_REQUIRED := 'N';
	      END IF;

		 IF (L_SEGMENTS.IS_ENABLED(J) ) THEN
			L_ENABLED := 'Y';
	      ELSE
			L_ENABLED := 'N';
	      END IF;

		 IF (L_SEGMENTS.IS_DISPLAYED(J) ) THEN
			L_DISPLAYED := 'Y';
	      ELSE
			L_DISPLAYED := 'N';
	      END IF;

		 IF (check_segment_existance(QP_APPLICATION_ID,
							    NEW_GDE_CONTEXT_CODE,
						         P_NEW_FLEXFIELD_NAME,
						         L_SEGMENTS.APPLICATION_COLUMN_NAME(J)) = TRUE ) THEN
		   --dbms_output.put_line ('First if');
		  IF (check_segment_name_existance(QP_APPLICATION_ID,
							    NEW_GDE_CONTEXT_CODE,
						         P_NEW_FLEXFIELD_NAME,
						         L_SEGMENTS.SEGMENT_NAME(J)) = TRUE ) THEN
		   --dbms_output.put_line ('Second if');
			p_segment_name := L_SEGMENTS.SEGMENT_NAME(J);
/*		  ELSE
		   --dbms_output.put_line ('Second else');
			p_segment_name := 'QP: ' || L_SEGMENTS.SEGMENT_NAME(J); -- Create new name
		  END IF;
*/
		   -- Storing the values for error handling
             p_context_name := NEW_GDE_CONTEXT_CODE;
		   p_application_column_name := L_SEGMENTS.APPLICATION_COLUMN_NAME(J);
		   p_application_id := QP_APPLICATION_ID;

		   --dbms_output.put_line ('Creating the Upgrade Context Segments');
		   BEGIN
		    FND_FLEX_DSC_API.MODIFY_SEGMENT (
		       P_APPL_SHORT_NAME => P_NEW_PRODUCT
		   ,   P_FLEXFIELD_NAME => P_NEW_FLEXFIELD_NAME
	        ,   P_CONTEXT_CODE   => NEW_GDE_CONTEXT_CODE
	        ,   P_SEGMENT_NAME  => p_segment_name
--		   ,   P_COLUMN_NAME   => L_SEGMENTS.APPLICATION_COLUMN_NAME(J)
		   ,   P_DEFAULT_TYPE	  => nvl(L_SEGMENTS.DEFAULT_TYPE(J),FND_API.G_MISS_CHAR)
		   ,   P_DEFAULT_VALUE  => L_SEGMENTS.DEFAULT_VALUE(J)
		   ,   P_REQUIRED       => L_REQUIRED
		   ,   P_SEQUENCE_NUMBER => L_SEGMENTS.SEQUENCE(J)
		   ,   P_ENABLED		  => L_ENABLED
		   ,   P_DISPLAYED      => L_DISPLAYED);
		   EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			rollback;
               Log_Error(p_id1 => -9999,
		               p_error_type => 'ERROR IN UPDATING SEGMENT',
		               p_error_desc => ' Application Id : '     || p_application_id ||
						           ' Old Flexfield Name : ' || P_FLEXFIELD_NAME ||
						           ' New Flexfield Name : ' || P_NEW_FLEXFIELD_NAME ||
						           ' Context Name : '       || p_context_name ||
						           ' Application Column Name : ' || p_application_column_name ||
						           ' Application Segment Name : ' || p_segment_name ,
		               p_error_module => 'QP_Update_Upgrade');
			raise;
		   END;
		 END IF;
		 END IF; -- vivek
	     END LOOP; -- L_SEGMENTS
	     --EXIT;
      END IF; -- Global Data Elements
	END LOOP; -- L_CONTEXTS

       --dbms_output.put_line('Total Context Count: ' || L_CONTEXTS.NCONTEXTS);
    -- Process other contexts(other than Global Data Elements)
    FOR I IN 1..L_CONTEXTS.NCONTEXTS LOOP
	 IF ((L_CONTEXTS.CONTEXT_CODE(I) <>  OLD_GDE_CONTEXT_CODE AND P_NEW_FLEXFIELD_NAME = G_QP_ATTR_DEFNS_PRICING)
		 OR (P_NEW_FLEXFIELD_NAME <> G_QP_ATTR_DEFNS_PRICING)) THEN
		  --dbms_output.put_line ('Before Other Context Existance Check');
		  --dbms_output.put_line ('Context Code : ' || L_CONTEXTS.CONTEXT_CODE(I));
/* vivek	    IF (check_context_existance(QP_APPLICATION_ID,P_NEW_FLEXFIELD_NAME,L_CONTEXTS.CONTEXT_CODE(I)) = FALSE) THEN
		  --dbms_output.put_line ('Creating Other Contexts');
            FND_FLEX_DSC_API.CREATE_CONTEXT ( P_NEW_PRODUCT
								   , P_NEW_FLEXFIELD_NAME
								   , L_CONTEXTS.CONTEXT_CODE(I)
								   , L_CONTEXTS.CONTEXT_NAME(I)
								   , L_CONTEXTS.CONTEXT_DESCRIPTION(I)
								   , 'Y'
								   , 'N') ;

		END IF;
	     FND_FLEX_DSC_API.ENABLE_CONTEXT ( P_NEW_PRODUCT
								, P_NEW_FLEXFIELD_NAME
								, L_CONTEXTS.CONTEXT_NAME(I)
								, TRUE );

		FND_FLEX_DSC_API.ENABLE_COLUMNS(P_NEW_PRODUCT
								, P_NEW_FLEXFIELD_NAME
								, 'ATTRIBUTE[0-9]+');
vivek */

		FND_DFLEX.GET_SEGMENTS ( FND_DFLEX.MAKE_CONTEXT( P_FLEXFIELD , L_CONTEXTS.CONTEXT_CODE(I))
					          ,L_SEGMENTS
					          , FALSE ) ;

          L_SEGMENT_COUNT := L_SEGMENTS.NSEGMENTS;
		--dbms_output.put_line ('Other Context Segment Count : ' || L_SEGMENT_COUNT);

		FOR J IN 1..L_SEGMENTS.NSEGMENTS LOOP
/* vivek		  L_VALUE_SET_ID := L_SEGMENTS.VALUE_SET(J);
		 BEGIN
		  IF L_VALUE_SET_ID <> 0 THEN
			SELECT FLEX_VALUE_SET_NAME INTO
			L_VALUE_SET
			FROM FND_FLEX_VALUE_SETS
			WHERE FLEX_VALUE_SET_ID = L_VALUE_SET_ID;
		  ELSE
			L_VALUE_SET := NULL;
		  END IF;
		 EXCEPTION
			WHEN NO_DATA_FOUND THEN
			   L_VALUE_SET := NULL;
			WHEN TOO_MANY_ROWS THEN
			  NULL;
		 END;
vivek */

		 IF (L_SEGMENTS.IS_REQUIRED(J) ) THEN
			L_REQUIRED := 'Y';
	      ELSE
			L_REQUIRED := 'N';
	      END IF;

		 IF (L_SEGMENTS.IS_ENABLED(J) ) THEN
			L_ENABLED := 'Y';
	      ELSE
			L_ENABLED := 'N';
	      END IF;

		 IF (L_SEGMENTS.IS_DISPLAYED(J) ) THEN
			L_DISPLAYED := 'Y';
	      ELSE
			L_DISPLAYED := 'N';
	      END IF;


		 IF (check_segment_existance(QP_APPLICATION_ID,
							    L_CONTEXTS.CONTEXT_CODE(I),
						         P_NEW_FLEXFIELD_NAME,
						         L_SEGMENTS.APPLICATION_COLUMN_NAME(J)) = TRUE ) THEN
		  --dbms_output.put_line ('Segment check false');
		  IF (check_segment_name_existance(QP_APPLICATION_ID,
--							    NEW_GDE_CONTEXT_CODE,
							    L_CONTEXTS.CONTEXT_CODE(I),
						         P_NEW_FLEXFIELD_NAME,
						         L_SEGMENTS.SEGMENT_NAME(J)) = TRUE ) THEN
		     --dbms_output.put_line ('Segment name check false');
			p_segment_name := L_SEGMENTS.SEGMENT_NAME(J);
/*		  ELSE
			p_segment_name := 'QP: ' || L_SEGMENTS.SEGMENT_NAME(J);
		  END IF;
*/
		   -- Storing the values for error handling
             p_context_name := L_CONTEXTS.CONTEXT_CODE(I);
		   p_application_column_name := L_SEGMENTS.APPLICATION_COLUMN_NAME(J);
		   p_application_id := QP_APPLICATION_ID;

		--dbms_output.put_line ('prod = '||P_NEW_PRODUCT);
		--dbms_output.put_line ('Flexfield Name : ' || P_NEW_FLEXFIELD_NAME);
		--dbms_output.put_line ('Context Code : ' || L_CONTEXTS.CONTEXT_CODE(I));
		--dbms_output.put_line ('p_seg_name = '||p_segment_name);
		--dbms_output.put_line ('Default type  : ' || L_SEGMENTS.DEFAULT_TYPE(J));

		   --dbms_output.put_line ('Creating Other Contexts Segments ');
		   BEGIN
		    FND_FLEX_DSC_API.MODIFY_SEGMENT (
		       P_APPL_SHORT_NAME => P_NEW_PRODUCT
		   ,   P_FLEXFIELD_NAME => P_NEW_FLEXFIELD_NAME
	        ,   P_CONTEXT_CODE   => L_CONTEXTS.CONTEXT_CODE(I)
	        ,   P_SEGMENT_NAME  => p_segment_name
--		   ,   P_COLUMN_NAME   => L_SEGMENTS.APPLICATION_COLUMN_NAME(J)
		   ,   P_DEFAULT_TYPE	  => nvl(L_SEGMENTS.DEFAULT_TYPE(J),FND_API.G_MISS_CHAR)
		   ,   P_DEFAULT_VALUE  => L_SEGMENTS.DEFAULT_VALUE(J)
		   ,   P_REQUIRED       => L_REQUIRED
		   ,   P_SEQUENCE_NUMBER => L_SEGMENTS.SEQUENCE(J)
		   ,   P_ENABLED		  => L_ENABLED
		   ,   P_DISPLAYED      => L_DISPLAYED);
		   EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			rollback;
               Log_Error(p_id1 => -9999,
		               p_error_type => 'ERROR IN UPDATE SEGMENT',
		               p_error_desc => ' Application Id : '     || p_application_id ||
						           ' Old Flexfield Name : ' || P_FLEXFIELD_NAME ||
						           ' New Flexfield Name : ' || P_NEW_FLEXFIELD_NAME ||
						           ' Context Name : '       || p_context_name ||
						           ' Application Column Name : ' || p_application_column_name ||
						           ' Application Segment Name : ' || p_segment_name ,
		               p_error_module => 'QP_Update_Upgrade');
			raise;
		   END ;
		END IF;
		END IF; -- vivek
         END LOOP; -- L_SEGMENTS

	     -- Append all the global data segments into other contexts
		--dbms_output.put_line ('Old GDE SEGMENTS Count : ' || nvl(GDE_SEGMENTS.NSEGMENTS,0));
	    IF (nvl(GDE_SEGMENTS.NSEGMENTS,0) > 0) THEN
		FOR K IN 1..GDE_SEGMENTS.NSEGMENTS LOOP
/* vivek		 L_VALUE_SET_ID := GDE_SEGMENTS.VALUE_SET(K);
		BEGIN
		 IF L_VALUE_SET_ID <> 0 THEN
			SELECT FLEX_VALUE_SET_NAME INTO
			L_VALUE_SET
			FROM FND_FLEX_VALUE_SETS
			WHERE FLEX_VALUE_SET_ID = L_VALUE_SET_ID;
		 ELSE
			L_VALUE_SET := NULL;
		 END IF;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			   L_VALUE_SET := NULL;
			WHEN TOO_MANY_ROWS THEN
			  NULL;
		END;
vivek */

		 IF (GDE_SEGMENTS.IS_REQUIRED(K) ) THEN
			L_REQUIRED := 'Y';
	      ELSE
			L_REQUIRED := 'N';
	      END IF;

		 IF (GDE_SEGMENTS.IS_ENABLED(K) ) THEN
			L_ENABLED := 'Y';
	      ELSE
			L_ENABLED := 'N';
	      END IF;

		 IF (GDE_SEGMENTS.IS_DISPLAYED(K) ) THEN
			L_DISPLAYED := 'Y';
	      ELSE
			L_DISPLAYED := 'N';
	      END IF;

/*
		--dbms_output.put_line ('Before Segment Existance Check for Old Gde Segments');
		--dbms_output.put_line ('Flexfield Name : ' || P_NEW_FLEXFIELD_NAME);
		--dbms_output.put_line ('Context Code : ' || L_CONTEXTS.CONTEXT_CODE(I));
		--dbms_output.put_line ('Application Column Name : ' || GDE_SEGMENTS.APPLICATION_COLUMN_NAME(K)); */
		 IF (check_segment_existance(QP_APPLICATION_ID,
							    L_CONTEXTS.CONTEXT_CODE(I),
						         P_NEW_FLEXFIELD_NAME,
						         GDE_SEGMENTS.APPLICATION_COLUMN_NAME(K)) = TRUE ) THEN
		  --dbms_output.put_line ('Segment check false');
		  IF (check_segment_name_existance(QP_APPLICATION_ID,
							    L_CONTEXTS.CONTEXT_CODE(I),
						         P_NEW_FLEXFIELD_NAME,
						         GDE_SEGMENTS.SEGMENT_NAME(K)) = TRUE ) THEN
		     --dbms_output.put_line ('Segment name check false');
			p_segment_name := GDE_SEGMENTS.SEGMENT_NAME(K);
/*		  ELSE
			p_segment_name := 'QP: ' || GDE_SEGMENTS.SEGMENT_NAME(K);
		  END IF;
*/
		   -- Storing the values for error handling
             p_context_name := L_CONTEXTS.CONTEXT_CODE(I);
		   p_application_column_name := GDE_SEGMENTS.APPLICATION_COLUMN_NAME(K);
		   p_application_id := QP_APPLICATION_ID;

		   --dbms_output.put_line ('Creating the OLD Gde segments to all contexts');
		   BEGIN
		    FND_FLEX_DSC_API.MODIFY_SEGMENT (
		       P_APPL_SHORT_NAME => P_NEW_PRODUCT
		   ,   P_FLEXFIELD_NAME => P_NEW_FLEXFIELD_NAME
	        ,   P_CONTEXT_CODE   => L_CONTEXTS.CONTEXT_CODE(I)
	        ,   P_SEGMENT_NAME  => p_segment_name
--		   ,   P_COLUMN_NAME   => GDE_SEGMENTS.APPLICATION_COLUMN_NAME(K)
		   ,   P_DEFAULT_TYPE	  => nvl(GDE_SEGMENTS.DEFAULT_TYPE(K),FND_API.G_MISS_CHAR)
		   ,   P_DEFAULT_VALUE  => GDE_SEGMENTS.DEFAULT_VALUE(K)
		   ,   P_REQUIRED       => L_REQUIRED
		   ,   P_SEQUENCE_NUMBER => GDE_SEGMENTS.SEQUENCE(K)
		   ,   P_ENABLED		  => L_ENABLED
		   ,   P_DISPLAYED      => L_DISPLAYED);
		   EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			rollback;
               Log_Error(p_id1 => -9999,
		               p_error_type => 'ERROR IN UPDATE SEGMENT',
		               p_error_desc => ' Application Id : '     || p_application_id ||
						           ' Old Flexfield Name : ' || P_FLEXFIELD_NAME ||
						           ' New Flexfield Name : ' || P_NEW_FLEXFIELD_NAME ||
						           ' Context Name : '       || p_context_name ||
						           ' Application Column Name : ' || p_application_column_name ||
						           ' Application Segment Name : ' || p_segment_name ,
		               p_error_module => 'QP_Update_Upgrade');
			raise;
		   END ;
		END IF;
		END IF; -- vivek
	    END LOOP; -- GDE_SEGMENTS
        END IF; -- GDE_SEGMENTS.NSEGMENTS > 0
	 END IF;   -- Global Data Elements
    END LOOP;   -- CONTEXTS
 END IF;  /*  CHECK FOR NEW FLEX FIELD STRUCTURE EXISTS */
EXCEPTION
	WHEN OTHERS THEN
	  --dbms_output.put_line(fnd_flex_dsc_api.message);
       rollback;
       Log_Error(p_id1 => -6501,
		    p_error_type => 'FLEXFIELD UPGRADE',
		    p_error_desc => fnd_flex_dsc_api.message,
		    p_error_module => 'QP_Update_Upgrade');
    raise;
END QP_UPDATE_UPGRADE;

PROCEDURE LOG_ERROR( P_ID1            VARCHAR2,
				   P_ID2			VARCHAR2  :=NULL,
				   P_ID3			VARCHAR2  :=NULL,
				   P_ID4			VARCHAR2  :=NULL,
				   P_ID5			VARCHAR2  :=NULL,
				   P_ID6			VARCHAR2  :=NULL,
				   P_ID7			VARCHAR2  :=NULL,
				   P_ID8			VARCHAR2  :=NULL,
				   P_ERROR_TYPE	VARCHAR2,
				   P_ERROR_DESC	VARCHAR2,
				   P_ERROR_MODULE	VARCHAR2) AS

  PRAGMA  AUTONOMOUS_TRANSACTION;

  BEGIN

    INSERT INTO QP_UPGRADE_ERRORS(ERROR_ID,UPG_SESSION_ID,ID1,ID2,ID3,ID4,ID5,ID6,ID7,ID8,ERROR_TYPE,
						    ERROR_DESC,ERROR_MODULE,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,
						    LAST_UPDATED_BY,LAST_UPDATE_LOGIN) VALUES
						    (QP_UPGRADE_ERRORS_S.NEXTVAL,USERENV('SESSIONID'),
						    P_ID1,P_ID2,P_ID3,P_ID4,P_ID5,P_ID6,P_ID7,P_ID8,
						    P_ERROR_TYPE, SUBSTR(P_ERROR_DESC,1,240),P_ERROR_MODULE,SYSDATE,
						    FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,FND_GLOBAL.LOGIN_ID);
    COMMIT;

  END;


END QP_UPGRADE_UTIL;

/
