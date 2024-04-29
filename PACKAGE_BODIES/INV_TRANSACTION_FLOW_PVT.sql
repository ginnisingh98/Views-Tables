--------------------------------------------------------
--  DDL for Package Body INV_TRANSACTION_FLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TRANSACTION_FLOW_PVT" AS
/* $Header: INVICTFB.pls 120.2 2006/08/14 12:02:01 anthiyag noship $ */
-- global variables
g_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
g_version_printed BOOLEAN := FALSE;
g_pkg_name VARCHAR2(30):='INV_TRANSACTION_FLOW_PVT';
g_miss_date DATE:=to_date(to_char(FND_API.G_MISS_DATE,'DD-MM-YYYY HH24:MI:SS'),'DD-MM-YYYY HH24:MI:SS');

--procedures

-- This procedure is used to write logs for debugging.
PROCEDURE DEBUG(p_message IN VARCHAR2,
                p_module   IN VARCHAR2 default 'abc',
                p_level   IN VARCHAR2 DEFAULT 9) IS
BEGIN
    IF NOT g_version_printed THEN
      INV_TRX_UTIL_PUB.TRACE('$Header: INVICTFB.pls 120.2 2006/08/14 12:02:01 anthiyag noship $',g_pkg_name, 9);
      g_version_printed := TRUE;
    END IF;
    INV_TRX_UTIL_PUB.TRACE( P_MESG =>P_MESSAGE
                           ,P_MOD => p_module
                           ,p_level => p_level
                           );
 END; -- DEBUG

/*=======================================================================================================*/

FUNCTION Validate_Operating_Unit(P_ORG_ID IN NUMBER) RETURN BOOLEAN IS
l_count NUMBER:=0;
BEGIN
         SELECT 1 INTO l_count FROM HR_OPERATING_UNITS
         WHERE ORGANIZATION_ID=P_ORG_ID
	 AND NVL(DATE_TO,SYSDATE) >= SYSDATE;
         RETURN TRUE;
EXCEPTION
         WHEN NO_DATA_FOUND THEN
         RETURN FALSE;
END;

/*=======================================================================================================*/

FUNCTION Validate_Organization(
                               P_ORGANIZATION_ID IN NUMBER,
                               P_ORG_ID          IN NUMBER
                              ) RETURN BOOLEAN IS
l_count NUMBER:=0;
BEGIN
         SELECT 1 INTO l_count FROM ORG_ORGANIZATION_DEFINITIONS
         WHERE ORGANIZATION_ID=P_ORGANIZATION_ID
         AND OPERATING_UNIT=P_ORG_ID
	 AND NVL(DISABLE_DATE,SYSDATE) >= SYSDATE;
         RETURN TRUE;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END;

/*=======================================================================================================*/

FUNCTION Validate_Qualifier_Code(P_QUALIFIER_CODE IN NUMBER)RETURN BOOLEAN IS
l_count NUMBER:=0;
BEGIN
        IF p_qualifier_code IS NOT NULL THEN
           SELECT 1 INTO l_count FROM MFG_LOOKUPS
           WHERE LOOKUP_TYPE='INV_TRANSACTION_FLOW_QUALIFIER'
           AND LOOKUP_CODE=p_qualifier_code;
           RETURN TRUE;
        ELSE
                RETURN TRUE;
        END IF;
EXCEPTION
         WHEN NO_DATA_FOUND THEN
                 RETURN FALSE;
END;

/*=======================================================================================================*/

FUNCTION Validate_Qualifier_Value(
				  P_QUALIFIER_CODE     IN NUMBER,
				  P_QUALIFIER_VALUE_ID IN NUMBER,
				  P_FLOW_TYPE          IN NUMBER
				  )RETURN BOOLEAN IS
  l_count NUMBER := 0;
BEGIN
  IF p_flow_type IS NOT NULL THEN
   IF p_qualifier_code IS NOT NULL THEN
	 IF p_qualifier_value_id IS NOT NULL THEN
	   IF p_qualifier_code=1 THEN -- Item Categories

         SELECT 1 INTO l_count FROM DUAL
		   WHERE P_QUALIFIER_VALUE_ID IN(
			      SELECT mcv.category_id
               FROM
			      mtl_categories_v mcv,
               MTL_CATEGORY_SET_VALID_CATS MCSVC,
               MTL_CATEGORY_SETS_b mcs
               WHERE
               mcs.category_set_id = decode(p_flow_type,1,1,2)
               and mcs.structure_id = mcv.structure_id
               and mcs.category_set_id = MCSVC.category_set_id
               and MCSVC.category_id =   mcv.category_id
               UNION
               SELECT mcv.category_id
               FROM mtl_categories_v mcv,
               MTL_CATEGORY_SETS_b mcs
               WHERE
               mcs.category_set_id = decode(p_flow_type,1,1,2)
               and mcs.structure_id = mcv.structure_id
               and mcs.default_category_id =   mcv.category_id
                 );

	     END IF;--p_qualifier_code=1

       IF l_count=1 THEN
        RETURN TRUE;
       ELSE
        RETURN FALSE;
       END IF;

    ELSE--p_qualifier_value_id IS  NULL
       RETURN FALSE;--When qualifier code is null , qualifier value id cannot be null
    END IF;--p_qualifier_value_id IS NOT NULL



   END IF;--p_qualifier_code IS NOT NULL
   END IF;--p_flow_type IS NOT NULL
EXCEPTION
         WHEN NO_DATA_FOUND THEN
                RETURN FALSE;
END;

/*=======================================================================================================*/

FUNCTION Validate_New_Accounting_Flag(
                                      P_START_ORG_ID             IN NUMBER,
				      P_END_ORG_ID               IN NUMBER,
				      P_FLOW_TYPE                IN NUMBER,
                                      P_NEW_ACCOUNTING_FLAG      IN VARCHAR2,
                                      P_NUM_LINES                IN VARCHAR2
                                     )RETURN BOOLEAN IS
BEGIN
         -- first validate for single OU flow
	 IF p_start_org_id=p_end_org_id THEN
	     IF p_new_accounting_flag IS NULL OR p_new_accounting_flag='N' THEN
                RETURN FALSE;
             ELSE
                RETURN TRUE;
             END IF;
	 END IF;
	 -- validate for multi ou setup
	 IF P_FLOW_TYPE=1 THEN -- Shipping
                IF P_NUM_LINES = 1 THEN
                   RETURN TRUE;
                ELSIF P_NUM_LINES>1 THEN
                   IF p_new_accounting_flag IS NULL OR p_new_accounting_flag='N' THEN
                      RETURN FALSE;
                   ELSE
                      RETURN TRUE;
                   END IF;
                ELSIF P_NUM_LINES =0 THEN
                  IF p_new_accounting_flag IS NULL OR p_new_accounting_flag='Y' THEN
                      RETURN FALSE;
                   ELSE
                      RETURN TRUE;
                   END IF;
                END IF;
         ELSIF P_FLOW_TYPE=2 THEN -- Procuring
            IF p_new_accounting_flag IS NULL OR p_new_accounting_flag='N' THEN
               RETURN FALSE;
            ELSE
               RETURN TRUE;
            END IF;
         END IF;

END Validate_New_Accounting_Flag;

/*=======================================================================================================*/
--This function checks if a transaction flow with same attribute
--already exists or not

/*FUNCTION Validate_Header(
		        P_HEADER_ID             IN      NUMBER,
			P_START_ORG_ID 		IN 	NUMBER,
			P_END_ORG_ID		IN	NUMBER,
			P_FLOW_TYPE		IN	NUMBER,
			P_ORGANIZATION_ID	IN	NUMBER,
			P_QUALIFIER_CODE	IN	NUMBER,
			P_QUALIFIER_VALUE_ID	IN	NUMBER,
			P_START_DATE		IN	DATE,
			P_END_DATE		IN	DATE
			) RETURN BOOLEAN IS

l_count NUMBER :=0;
BEGIN
	 -- check duplicate
	 BEGIN

		 SELECT 1 INTO l_count FROM DUAL
		 WHERE EXISTS (SELECT HEADER_ID FROM MTL_TRANSACTION_FLOW_HEADERS
		               WHERE HEADER_ID <> NVL(P_HEADER_ID,-999)
			       AND START_ORG_ID=P_START_ORG_ID
			       AND END_ORG_ID=P_END_ORG_ID
			       AND FLOW_TYPE=P_FLOW_TYPE
			       --AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
			       AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
			       AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-999)
			       AND START_DATE=P_START_DATE
			       AND NVL(END_DATE,SYSDATE)=NVL(P_END_DATE,SYSDATE));
	EXCEPTION
		 WHEN NO_DATA_FOUND THEN
		 -- No duplicate transaction flow exists
		 RETURN TRUE;
	END;
	-- if control coming to this place then duplicate transaction flow exists
	FND_MESSAGE.SET_NAME('INV','INV_DUPLICATE_TRX_FLOW');
	FND_MSG_PUB.ADD;
	RETURN FALSE;
END Validate_Header;*/

/*=======================================================================================================*/

--This procedure validates the start date

FUNCTION Validate_Start_Date(
			 P_HEADER_ID            IN                      NUMBER,
			 P_START_ORG_ID 	IN 			NUMBER,
			 P_END_ORG_ID		IN			NUMBER,
			 P_FLOW_TYPE		IN			NUMBER,
			 P_ORGANIZATION_ID	IN			NUMBER,
			 P_QUALIFIER_CODE	IN			NUMBER,
			 P_QUALIFIER_VALUE_ID	IN			NUMBER,
			 P_START_DATE		IN			DATE,
			 P_REF_DATE		IN 			DATE
		)  return BOOLEAN IS
l_count NUMBER:=0;
BEGIN
   IF g_debug=1 THEN
      debug('The value of p_start_date '||to_char(p_start_date,'DD-MON-YYYY HH24:MI:SS'),'Validate_Start_Date');
      debug('The value of p_ref_date '||to_char(p_ref_date,'DD-MON-YYYY HH24:MI:SS'),'Validate_Start_Date');
   END IF;
   -- start date should not be less then the sysdate (passed in ref date)
   IF p_start_date < p_ref_date THEN
      IF g_debug=1 THEN
         debug('p_start_date is less than p_ref_date','Validate_Start_Date');
      END IF;
      FND_MESSAGE.SET_NAME('INV','INV_INVALID_START_DATE');
      FND_MSG_PUB.ADD;
      RETURN FALSE;
    END IF;
 /*
    -- start date should not fall between any other transaction
    --flow's start and end date with same attributes
    --overlap check
    BEGIN
	-- check if a transaction flow with start date < p_start_date
	SELECT 1 INTO l_count FROM DUAL
	WHERE EXISTS (SELECT HEADER_ID FROM MTL_TRANSACTION_FLOW_HEADERS
			    WHERE HEADER_ID <> NVL(P_HEADER_ID,-999)
			    AND START_ORG_ID=P_START_ORG_ID
			    AND END_ORG_ID=P_END_ORG_ID
			    AND FLOW_TYPE=P_FLOW_TYPE
			    AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
			    AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
			    AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-999)
			    AND START_DATE<=P_START_DATE);
			    -- there is possiblity of overlaping
			    -- proceed to check overlaps
			    IF g_debug=1 THEN
				debug(' Going to check overlaps','Validate_Start_Date');
			    END IF;
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	  -- overlap not possible for p_start_date
	  IF g_debug=1 THEN
	     debug('No overlapping transaction flow exists','Validate_Start_Date');
	  END IF;
	RETURN TRUE; -- no overlaping transaction flow exists
    END;
    --
    BEGIN
	--check if a transaction flow with null end date and
	--start date < p_start_date exists
	SELECT 1 INTO l_count FROM DUAL
	WHERE EXISTS (SELECT HEADER_ID FROM MTL_TRANSACTION_FLOW_HEADERS
		    WHERE HEADER_ID <> NVL(P_HEADER_ID,-999)
		    AND START_ORG_ID=P_START_ORG_ID
		    AND END_ORG_ID=P_END_ORG_ID
		    AND FLOW_TYPE=P_FLOW_TYPE
		    AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
		    AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
		    AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-999)
		    AND START_DATE<=P_START_DATE
		    AND END_DATE IS NULL);
		    -- overlap found
		    --
 		    IF g_debug=1 THEN
		        debug('Overlap found for start_date<p_start_date and end_date = null','Validate_Start_Date');
		    END IF;
		    FND_MESSAGE.SET_NAME('INV','INV_OVERLAPING_TRX_FLOW');
		    FND_MSG_PUB.ADD;
		    RETURN FALSE;
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
              IF g_debug=1 THEN
                 debug('Finding overlap for end_date not null','Validate_Start_Date');
	      END IF;
              BEGIN
		  -- check if a transaction flow with not null end date
                  --and start date < p_start_date exists
		  SELECT 1 INTO l_count FROM DUAL
		  WHERE EXISTS (SELECT HEADER_ID FROM MTL_TRANSACTION_FLOW_HEADERS
   		  		    WHERE HEADER_ID <> NVL(P_HEADER_ID,-999)
				    AND START_ORG_ID=P_START_ORG_ID
   				    AND END_ORG_ID=P_END_ORG_ID
   				    AND FLOW_TYPE=P_FLOW_TYPE
   				    AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
   				    AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
   				    AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-999)
   				    AND START_DATE<=P_START_DATE
   		                    AND END_DATE>=P_START_DATE );
				    -- overlap found
				    IF g_debug=1 THEN
				       debug('Overlap found for start_date<p_start_date and end_date>p_start_date','Validate_Start_Date');
				    END IF;
				    FND_MESSAGE.SET_NAME('INV','INV_OVERLAPING_TRX_FLOW');
				    FND_MSG_PUB.ADD;
				    RETURN FALSE;
	      EXCEPTION
		WHEN NO_DATA_FOUND THEN
		     -- no overlaping transaction flow exists
                     IF g_debug=1 THEN
                        debug('No Overlap exists','Validate_Start_Date');
		     END IF;
                     RETURN TRUE;

	      END;
    END;
    */
	BEGIN
		SELECT 1 INTO l_count FROM DUAL
		  WHERE EXISTS (SELECT HEADER_ID FROM MTL_TRANSACTION_FLOW_HEADERS
   		  		    WHERE HEADER_ID <> NVL(P_HEADER_ID,-999)
				    AND START_ORG_ID=P_START_ORG_ID
   				    AND END_ORG_ID=P_END_ORG_ID
   				    AND FLOW_TYPE=P_FLOW_TYPE
   				    AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
   				    AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
   				    AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-999)
   				    AND START_DATE<=P_START_DATE
   		                    AND NVL(END_DATE,g_miss_date)>=P_START_DATE );
	    IF g_debug=1 THEN
	      debug('Overlap found for start date','Validate_Start_Date');
	    END IF;
	    FND_MESSAGE.SET_NAME('INV','INV_OVERLAPING_TRX_FLOW');
        FND_MESSAGE.SET_TOKEN('START_END','START_DATE_CAP',TRUE);
	    FND_MSG_PUB.ADD;
	    RETURN FALSE;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		RETURN TRUE;
	END;

END Validate_Start_Date;

/*=======================================================================================================*/

FUNCTION Validate_End_Date(
			 P_HEADER_ID            IN      NUMBER,
			 P_START_ORG_ID 	IN 	NUMBER,
			 P_END_ORG_ID		IN	NUMBER,
			 P_FLOW_TYPE		IN	NUMBER,
			 P_ORGANIZATION_ID	IN	NUMBER,
			 P_QUALIFIER_CODE	IN	NUMBER,
			 P_QUALIFIER_VALUE_ID	IN	NUMBER,
			 P_START_DATE		IN	DATE,
			 P_END_DATE		IN	DATE,
			 P_REF_DATE		IN	DATE
		  ) RETURN BOOLEAN IS
l_count NUMBER:=0;
BEGIN
     IF g_debug=1 THEN
        debug('The value of p_start_date '||to_char(p_start_date,'DD-MON-YYYY HH24:MI:SS'),'Validate_End_Date');
        debug('The value of p_ref_date '||to_char(p_ref_date,'DD-MON-YYYY HH24:MI:SS'),'Validate_End_Date');
     END IF;
     -- end date should be >= p_ref_date
     IF p_end_date<p_ref_date THEN
        IF g_debug=1 THEN
           debug('I am in if when the end date is < p_ref_date','Validate_End_Date');
	END IF;
        FND_MESSAGE.SET_NAME('INV','INV_NOT_CUR_END_DATE');
        FND_MSG_PUB.ADD;
	RETURN FALSE;
     END IF;
     -- end date should not be <= start date
     IF p_end_date <=p_start_date THEN
        IF g_debug=1 THEN
           debug('p_end_date is <= p_ref_date','Validate_End_Date');
	END IF;
        FND_MESSAGE.SET_NAME('INV','INV_END_DATE_INVALID');
        FND_MSG_PUB.ADD;
	RETURN FALSE;
     END IF;

/*
     --
     -- end date should not fall between start and end date of any other transaction flow with same attributes
     -- overlap check
     IF p_end_date IS NULL THEN
	-- All transaction flows with same attributes should have end date less then the start date of this transaction
	BEGIN
	   SELECT 1 INTO l_count FROM DUAL
           WHERE EXISTS (SELECT HEADER_ID FROM MTL_TRANSACTION_FLOW_HEADERS
		      WHERE  START_ORG_ID=P_START_ORG_ID
		      AND HEADER_ID <> NVL(P_HEADER_ID,-999)
		      AND END_ORG_ID=P_END_ORG_ID
		      AND FLOW_TYPE=P_FLOW_TYPE
		      AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
		      AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
		      AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-999)
		      AND END_DATE>=P_START_DATE);
		      IF g_debug=1 THEN
                         debug('Overlap found for end_date>=p_start_date and p_end_date is null','Validate_End_Date');
		      END IF;
		      FND_MESSAGE.SET_NAME('INV','INV_OVERLAPING_TRX_FLOW');
		      FND_MSG_PUB.ADD;
		      RETURN FALSE;
	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	    -- no overlap for end_date>=p_start_date and p_end_date is null
            IF g_debug=1 THEN
                debug('No overlap for end_date>=p_start_date and p_end_date is null','Validate_End_Date');
	    END IF;
            RETURN TRUE;
	END;
     ELSE -- p_end_date is NOT null
	BEGIN
	  -- If a Inter-company Transaction Flow with same attributes and NULL End Date exists
	  -- Then new Inter-company Transaction Flow can only be
          -- defined for End Date less then
	  -- the Start Date of existing Inter-company Transaction Flow
          SELECT 1 INTO l_count FROM DUAL
          WHERE EXISTS (SELECT HEADER_ID FROM MTL_TRANSACTION_FLOW_HEADERS
	  	        WHERE HEADER_ID <> NVL(P_HEADER_ID,-999)
		        AND START_ORG_ID=P_START_ORG_ID
		        AND END_ORG_ID=P_END_ORG_ID
		        AND FLOW_TYPE=P_FLOW_TYPE
		        AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
		        AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
		        AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-999)
		        AND START_DATE<=P_END_DATE
		        AND END_DATE IS NULL);
			-- overlap found
			IF g_debug=1 THEN
			   debug('Overlap found for start_date<=p_end_date and end_date is null','Validate_End_Date');
			END IF;
			FND_MESSAGE.SET_NAME('INV','INV_OVERLAPING_TRX_FLOW');
			FND_MSG_PUB.ADD;
			RETURN FALSE;
	 EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	         BEGIN
		     -- End Date should be less than the Start Date of any other Inter-company
		     -- Transaction Flow with same attributes and Start Date greater than the
		     -- Start Date of current Inter-company Transaction Flow
		     SELECT 1 INTO l_count FROM DUAL
		     WHERE EXISTS (SELECT HEADER_ID FROM MTL_TRANSACTION_FLOW_HEADERS
		                   WHERE HEADER_ID <> NVL(P_HEADER_ID,-999)
				   AND START_ORG_ID=P_START_ORG_ID
				   AND END_ORG_ID=P_END_ORG_ID
				   AND FLOW_TYPE=P_FLOW_TYPE
				   AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
				   AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
				   AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-999)
				   AND START_DATE<=P_END_DATE
				   AND START_DATE>=P_START_DATE
				   AND END_DATE IS NOT NULL);
				   -- overlap found
				   IF g_debug=1 THEN
				      debug('Overlap found for start_date<=p_end_date and start_date>=p_start_date','Validate_End_Date');
				   END IF;
				   FND_MESSAGE.SET_NAME('INV','INV_OVERLAPING_TRX_FLOW');
				   FND_MSG_PUB.ADD;
				   RETURN FALSE;
	         EXCEPTION
		    WHEN NO_DATA_FOUND THEN
                       IF g_debug=1 THEN
		          debug('No overlap found','Validate_End_Date');
			END IF;
                        RETURN TRUE;
		 END;
	END;
	-- overlap exists
     END IF;--p_end_date

     */
	BEGIN
	     SELECT 1 INTO l_count FROM DUAL
	     WHERE EXISTS (SELECT HEADER_ID FROM MTL_TRANSACTION_FLOW_HEADERS
			   WHERE HEADER_ID <> NVL(P_HEADER_ID,-999)
			   AND START_ORG_ID=P_START_ORG_ID
			   AND END_ORG_ID=P_END_ORG_ID
			   AND FLOW_TYPE=P_FLOW_TYPE
			   AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
			   AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
			   AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-999)
			   AND START_DATE>=P_START_DATE
			   AND START_DATE<=NVL(P_END_DATE,G_MISS_DATE)
			   );
	   -- overlap found
	   IF g_debug=1 THEN
	      debug('Overlap found end date','Validate_End_Date');
	   END IF;
	   FND_MESSAGE.SET_NAME('INV','INV_OVERLAPING_TRX_FLOW');
	   FND_MESSAGE.SET_TOKEN('START_END','END_DATE_CAP',TRUE);
	   FND_MSG_PUB.ADD;
	   RETURN FALSE;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
                IF g_debug=1 THEN
		   debug('No overlap found','Validate_End_Date');
		END IF;
                RETURN TRUE;
	END;

END Validate_End_Date;

/*=======================================================================================================*/

PROCEDURE Gap_Exists(
                      X_START_DATE		OUT NOCOPY	DATE,
                      X_END_DATE		OUT NOCOPY      DATE,
		      X_REF_DATE                OUT NOCOPY      DATE,
                      X_GAP_EXISTS		OUT NOCOPY      BOOLEAN,
		      X_RETURN_STATUS           OUT NOCOPY      NUMBER,
                      P_START_ORG_ID 		IN 		NUMBER,
                      P_END_ORG_ID		IN		NUMBER,
                      P_FLOW_TYPE		IN		NUMBER,
                      P_ORGANIZATION_ID		IN		NUMBER,
                      P_QUALIFIER_CODE		IN		NUMBER,
                      P_QUALIFIER_VALUE_ID	IN		NUMBER
					 )IS
CURSOR DATES(p_sysdate DATE) IS
	   SELECT START_DATE,END_DATE
	   FROM MTL_TRANSACTION_FLOW_HEADERS
	   WHERE START_ORG_ID=P_START_ORG_ID
	   AND END_ORG_ID=P_END_ORG_ID
           AND FLOW_TYPE=P_FLOW_TYPE
           AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
           AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
           AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-999)
	   AND ( END_DATE>=p_sysdate OR END_DATE  IS NULL )
	   ORDER BY START_DATE;
--
l_temp_date DATE;
l_diff NUMBER;
l_count NUMBER:=0;
l_start_date DATE;
l_end_date DATE;
l_sysdate DATE:=sysdate;

--
BEGIN

	 x_gap_exists:=FALSE;
	 -- get trx flow with min start date and end date > sysdate or null
	 BEGIN
		SELECT MIN(START_DATE)
		INTO l_start_date
		FROM MTL_TRANSACTION_FLOW_HEADERS
		WHERE START_ORG_ID=P_START_ORG_ID
		AND END_ORG_ID=P_END_ORG_ID
		AND FLOW_TYPE=P_FLOW_TYPE
		AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
		AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
		AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-999)
		AND (END_DATE > l_sysdate OR END_DATE IS NULL);

		IF l_start_date>=l_sysdate THEN
		   -- gap exists at present date
		   x_gap_exists:=TRUE;
		   x_ref_date:=l_sysdate;
		   x_start_date:=l_sysdate-(1/(24*60*60)); -- 1 sec is added in the called program
		   x_end_date:=l_start_date;
		   IF g_debug=1 THEN
		      debug('The value of x_start_date is'||x_start_date,'Gap_Exists');
		      debug('The value of x_end_date is'||x_end_date,'Gap_Exists');
		      debug('The value of x_ref_date is'||x_ref_date,'Gap_Exists');
	           END IF;
		ELSIF l_start_date<l_sysdate THEN
		      -- need to search for gap
		       OPEN dates(l_sysdate);
			 FETCH dates INTO l_start_date,l_temp_date;

			 IF g_debug=1 THEN
			     debug('The value of l_start_date in first fetch is'||l_start_date,'Gap_Exists');
			     debug('The value of l_temp_date in first fetch is'||l_temp_date,'Gap_Exists');
			 END IF;

			 IF l_temp_date IS NOT NULL THEN
			    -- if end_date of first record is null then gap can not exist for future
			    -- The case of current gap is already handeled in previous block
			    --
			    LOOP
				FETCH dates INTO l_start_date,l_end_date;
				EXIT WHEN dates%NOTFOUND OR l_count=1;
				IF g_debug=1 THEN
				   debug('The value of l_start_date in second fetch is'||l_start_date,'Gap_Exists');
				   debug('The value of l_end_date in second fetch is'||l_end_date,'Gap_Exists');
				END IF;
				-- get the difference in seconds between end date of previous transaction flow
				-- and start date of next trx flow
				l_diff := trunc(l_start_date-l_temp_date,10)*(24*60*60); -- convert to seconds
				IF g_debug=1 THEN
				   debug('The value of diff is'||l_diff,'Gap_Exists');
				END IF;
				IF l_diff >1 THEN
				   IF g_debug=1 THEN
				      debug('I am in if','Gap_Exists');
				   END IF;
				   x_gap_exists:=TRUE;
				   x_start_date:=l_temp_date;
				   x_end_date:=l_start_date;
				   x_ref_date:=l_sysdate; -- should be latest sysdate
				   l_count:=1;
				ELSE
				   l_temp_date:=l_end_date;
				   IF g_debug=1 THEN
				      debug('I am in else l_end_date =' ||l_end_date,'Gap_Exists');
				   END IF;
				END IF;
				IF l_end_date IS NULL THEN
				   IF g_debug=1 THEN
				      debug('I am here if future end date is null','Gap_Exists');
				   END IF;
				   -- if end_date of any record is null no more record can exists
				   x_return_status:=1;
				   EXIT;
				END IF;
			    END LOOP;--dates
			  END IF;--l_temp_date is not null
			CLOSE dates;
		END IF;
	 EXCEPTION
		WHEN NO_DATA_FOUND THEN
		-- This case is not possible
		IF g_debug=1 THEN
	           debug('In no data found'||l_start_date,'Gap_Exists');
		END IF;
		NULL;

	 END;
EXCEPTION
	WHEN OTHERS THEN
	IF g_debug=1 THEN
	   debug('When others '||sqlerrm,'Gap_Exists');
	END IF;

END Gap_Exists;


/*=======================================================================================================*/

PROCEDURE Get_Default_Dates(
                            X_START_DATE	  OUT NOCOPY	  DATE,
		            X_END_DATE            OUT NOCOPY      DATE,
                            X_REF_DATE		  OUT NOCOPY      DATE,
                            X_RETURN_CODE         OUT NOCOPY      NUMBER,
                            P_START_ORG_ID 	  IN 		  NUMBER,
                            P_END_ORG_ID	  IN		  NUMBER,
                            P_FLOW_TYPE		  IN		  NUMBER,
                            P_ORGANIZATION_ID	  IN		  NUMBER,
                            P_QUALIFIER_CODE	  IN		  NUMBER,
                            P_QUALIFIER_VALUE_ID  IN		  NUMBER
			)IS
--
l_count NUMBER:=0;
l_start_date DATE;
l_end_date DATE;
l_ref_date DATE;
l_gap_exists BOOLEAN:=FALSE;
l_return_status NUMBER:=0;

/*
	L_RETURN_CODE	0=>	ERROR
			1=>	NO_TRX - START_DATE=SYSDATE, END_DATE=NULL
			2=>	GAP - START DATE= END DATE, END_DATE= NEXT START DATE
			3=>	NO GAP - START_DATE=MAX END DATE, END DATE= NULL
*/
BEGIN

	IF g_debug=1 THEN
           debug('Inside Get_Default_Dates','Get_Default_Dates');
	END IF;
	x_return_code:=0;
	-- If a transaction flow with NULL end date exists then no other
        --transaction flow can be created
	BEGIN
   		SELECT 1 INTO l_count FROM DUAL
		WHERE EXISTS (SELECT HEADER_ID FROM MTL_TRANSACTION_FLOW_HEADERS
			      WHERE START_ORG_ID=P_START_ORG_ID
			      AND END_ORG_ID=P_END_ORG_ID
			      AND FLOW_TYPE=P_FLOW_TYPE
			      AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
			      AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
			      AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-999)
			      AND START_DATE<=SYSDATE
			      AND END_DATE IS NULL);
		x_return_code:=0;
		IF g_debug=1 THEN
		   debug('Null end date case','Get_Default_Dates');
		END IF;
		FND_MESSAGE.SET_NAME('INV','INV_NULL_END_DATE');
		FND_MSG_PUB.ADD;
		RETURN;
	EXCEPTION
   		WHEN NO_DATA_FOUND THEN
		   NULL;
		-- proceed to next section
	END;


	-- if no trx flow with same attributes  and end_date greater than sysdate or null exists
	-- then default the start date to sysdate
	BEGIN
   		SELECT 1 INTO l_count FROM DUAL
		WHERE EXISTS (SELECT HEADER_ID FROM MTL_TRANSACTION_FLOW_HEADERS
			      WHERE START_ORG_ID=P_START_ORG_ID
			      AND END_ORG_ID=P_END_ORG_ID
			      AND FLOW_TYPE=P_FLOW_TYPE
			      AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
			      AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
			      AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-999)
			      AND (END_DATE > SYSDATE OR END_DATE IS NULL));
		-- if a record is found then need to find the first gap
		-- proceed to next block
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		-- return sysdate as default start date and set p_ref_date to start date
		IF g_debug=1 THEN
		   debug('No present or future trx flow found','Get_Default_Dates');
		END IF;
		X_RETURN_CODE:=1;
		X_START_DATE:=SYSDATE;
		X_REF_DATE:=X_START_DATE;
		IF g_debug=1 THEN
		   debug('X_START_DATE = '||to_char(X_START_DATE,'DD-MON-YYY HH24:MI:SS'),'Get_Default_Dates');
		   debug('X_REF_DATE = '||to_char(X_REF_DATE,'DD-MON-YYY HH24:MI:SS'),'Get_Default_Dates');
                END IF;
		RETURN; -- no further processing required
	END;

	-- some transaction flow are existing
	-- find the first gap and set the start and end dates

	IF g_debug=1 THEN
           debug('Calling gap exists','Get_Default_Dates');
	END IF;

	Gap_Exists(
		 X_START_DATE	 	 =>l_start_date,
		 X_END_DATE		 =>l_end_date,
		 X_REF_DATE		 =>l_ref_date,
		 X_GAP_EXISTS		 =>l_gap_exists,
		 X_RETURN_STATUS         =>l_return_status,
		 P_START_ORG_ID 	 =>p_start_org_id,
		 P_END_ORG_ID		 =>p_end_org_id,
		 P_FLOW_TYPE		 =>p_flow_type,
		 P_ORGANIZATION_ID	 =>p_organization_id,
		 P_QUALIFIER_CODE	 =>p_qualifier_code,
		 P_QUALIFIER_VALUE_ID    =>p_qualifier_value_id
	 );
        --A future trxn with null end date exists
         IF g_debug=1 THEN
	   debug('The value of l_return_status is'||l_return_status,'Get_Default_Dates');
        END IF;
        IF l_return_status=1 THEN
	x_return_code:=0;
        FND_MESSAGE.SET_NAME('INV','INV_NULL_END_DATE');
	FND_MSG_PUB.ADD;
        RETURN;
	END IF;--no further processing to be done
	IF g_debug=1 THEN
	   debug('The value of l_start_date is'||l_start_date,'Get_Default_Dates');
           debug('The value of l_end_date is'||l_end_date,'Get_Default_Dates');
        END IF;

	IF l_gap_exists THEN
           x_start_date:=l_start_date;
           x_end_date:=l_end_date;
           x_ref_date:=l_ref_date;
           x_return_code:=2;
	   IF g_debug=1 THEN
              debug('gap exists is true','Get_Default_Dates');
	      debug('Out parameter set from get default dates'||l_count,'Get_Default_Dates');
              debug('The value of x_start_date in is'||to_char(x_start_date,'DD-MON-YYYY HH24:MI:SS'),'Get_Default_Dates');
	      debug('The value of x_end_date is'||to_char(x_end_date,'DD-MON-YYYY HH24:MI:SS'),'Get_Default_Dates');
	      debug('The value of x_ref_date is'||to_char(x_ref_date,'DD-MON-YYYY HH24:MI:SS'),'Get_Default_Dates');
           END IF;
	ELSE
        -- set the start date to max of end date
	debug('gap exists is false','Get_Default_Dates');
	 BEGIN
	    SELECT MAX(END_DATE) INTO L_START_DATE FROM MTL_TRANSACTION_FLOW_HEADERS
	    WHERE START_ORG_ID=P_START_ORG_ID
	    AND END_ORG_ID=P_END_ORG_ID
	    AND FLOW_TYPE=P_FLOW_TYPE
	    AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
	    AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
	    AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-999)
	    AND END_DATE>SYSDATE;
	    x_return_code:=3;
	    x_start_date:=l_start_date+(1/(24*60*60));
	    x_ref_date:=x_start_date;
	 EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		NULL;
         END;
	END IF;
	debug('Returning from get default dates '||l_count,'Get_Default_Dates');
END Get_Default_Dates;

/*=======================================================================================================*/

/**
  * This function will return TRUE if a gap will be created because of the current transaction else false
  */

FUNCTION New_Gap_Created(
			P_START_ORG_ID 		IN 	NUMBER,
			P_END_ORG_ID		IN 	NUMBER,
			P_FLOW_TYPE		IN	NUMBER,
			P_ORGANIZATION_ID	IN	NUMBER,
			P_QUALIFIER_CODE	IN	NUMBER,
			P_QUALIFIER_VALUE_ID	IN	NUMBER,
			P_START_DATE		IN	DATE,
			P_END_DATE		IN	DATE,
			P_REF_DATE		IN	DATE
		      ) RETURN BOOLEAN IS
l_count NUMBER:=0;
BEGIN
	 IF g_debug=1 THEN
	    debug('The value of p_start_date in is'||to_char(p_start_date,'DD-MON-YYYY HH24:MI:SS'),'New_Gap_Created');
	    debug('The value of p_end_date is'||to_char(p_end_date,'DD-MON-YYYY HH24:MI:SS'),'New_Gap_Created');
	    debug('The value of p_ref_date is'||to_char(p_ref_date,'DD-MON-YYYY HH24:MI:SS'),'New_Gap_Created');
        END IF;
	IF p_end_date IS NULL THEN -- if end date is null then gap will exist only at start
	   IF p_start_date=p_ref_date THEN
	      -- no gap created
	      RETURN FALSE;
	   ELSIF p_start_date>p_ref_date THEN
	         -- a transaction flow with end date = start_date-1second should exists
		 BEGIN
			SELECT 1 INTO l_count FROM MTL_TRANSACTION_FLOW_HEADERS
			WHERE START_ORG_ID=P_START_ORG_ID
		        AND END_ORG_ID=P_END_ORG_ID
		        AND FLOW_TYPE=P_FLOW_TYPE
		        AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
		        AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
		        AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-999)
			AND END_DATE=P_START_DATE-(1/(24*60*60));
			-- no gap created
			RETURN FALSE;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			-- gap created
			FND_MESSAGE.SET_NAME('INV','INV_GAP_CREATED');
			FND_MSG_PUB.ADD;
			if g_debug=1 then
			   debug('Gap created for condition p_start_date>p_ref_date','New_Gap_Created');
			end if;
			RETURN TRUE;

		END;
	   ELSE -- only possible with update
	     RETURN FALSE;
	   END IF;
	ELSE -- gap may exists at end also
	    IF p_start_date>p_ref_date THEN
		   BEGIN
			-- check gap for start date
			SELECT 1 INTO l_count FROM MTL_TRANSACTION_FLOW_HEADERS
			WHERE START_ORG_ID=P_START_ORG_ID
			AND END_ORG_ID=P_END_ORG_ID
			AND FLOW_TYPE=P_FLOW_TYPE
			AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
			AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
			AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-999)
			AND END_DATE=P_START_DATE-(1/(24*60*60));
		    EXCEPTION
			WHEN NO_DATA_FOUND THEN
			-- gap created
			FND_MESSAGE.SET_NAME('INV','INV_GAP_CREATED');
			FND_MSG_PUB.ADD;
			if g_debug=1 then
			   debug('Gap created for start date when p_start_date>p_ref_date','New_Gap_Created');
			end if;
			RETURN TRUE;
		    END;
	    END IF;

	    -- check gap for end date
	    BEGIN
		SELECT 1 INTO l_count FROM MTL_TRANSACTION_FLOW_HEADERS
		WHERE START_ORG_ID=P_START_ORG_ID
		AND END_ORG_ID=P_END_ORG_ID
		AND FLOW_TYPE=P_FLOW_TYPE
		AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
		AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
		AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-9)
		AND START_DATE>P_END_DATE+(1/(24*60*60))
		AND ROWNUM=1; -- multiple records are possible
		-- a gap for end date can occr only if above sql will return a value
		if g_debug=1 then
	           debug('Condition for gap for end gate satisfied','New_Gap_Created');
	        end if;
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		-- no gap can exists
		RETURN FALSE;
	    END;
	    -- if control is coming to this place means that a transaction flow
	    -- with start date greater the end date of current trx flow exists
	    -- we need to check for gap due to end date
	    BEGIN
		SELECT 1 INTO l_count FROM MTL_TRANSACTION_FLOW_HEADERS
		WHERE START_ORG_ID=P_START_ORG_ID
		AND END_ORG_ID=P_END_ORG_ID
		AND FLOW_TYPE=P_FLOW_TYPE
		AND NVL(ORGANIZATION_ID,-999)=NVL(P_ORGANIZATION_ID,-999)
		AND NVL(QUALIFIER_CODE,-999)=NVL(P_QUALIFIER_CODE,-999)
		AND NVL(QUALIFIER_VALUE_ID,-999)=NVL(P_QUALIFIER_VALUE_ID,-9)
		AND START_DATE=P_END_DATE+(1/(24*60*60));
		-- all validation passed
		-- no gap created
		RETURN FALSE;
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		-- gap created
		FND_MESSAGE.SET_NAME('INV','INV_GAP_CREATED');
		FND_MSG_PUB.ADD;
		if g_debug=1 then
	           debug('Gap created for condition p_end_date > start_date+1sec','New_Gap_Created');
		end if;
		RETURN TRUE;
	    END;

	END IF;
END New_Gap_Created;

/*=======================================================================================================*/


FUNCTION Validate_Inv_Organization_Type(
                                        P_FLOW_TYPE             IN NUMBER,
                                        P_ORGANIZATION_IDS      IN TABLE_OF_NUMBERS,
                                        P_NEW_ACCOUNTING_FLAG   IN VARCHAR2
                                        ) RETURN BOOLEAN IS

l_count NUMBER :=0;
l_count_disc NUMBER:=0;

BEGIN
         -- VALIDATE EACH ORG
         FOR l_index IN 1..P_ORGANIZATION_IDS.COUNT
         LOOP
		IF p_flow_type=1 THEN -- shipping
                        IF p_new_accounting_flag='Y' THEN
                           -- All orgs should be non process
			   /* ANTHIYAG Bug#5460153 14-Aug-2006 Start */
			   /*
                           BEGIN
                                SELECT 1 INTO l_count FROM MTL_PARAMETERS
                                WHERE ORGANIZATION_ID=P_ORGANIZATION_IDS(l_index)
                                AND PROCESS_ENABLED_FLAG='Y';
                                -- if a record is found then its a failure condition
                                -- process enabled orgs are not supported  for global procuring transaction
                                FND_MESSAGE.SET_NAME('INV','INV_PROCESS_ORG_NOT_ALLOWED');
                                FND_MSG_PUB.ADD;
                                RETURN FALSE;
                           EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                NULL;
                                -- success condition
                           END;
			   */
			   NULL;
			   /* ANTHIYAG Bug#5460153 14-Aug-2006 End */
                        ELSE
                           -- Old accounting All orgs should be either process or discrete
                           BEGIN
                                -- get process org
                                SELECT 1 INTO l_count FROM MTL_PARAMETERS
                                WHERE ORGANIZATION_ID=P_ORGANIZATION_IDS(l_index)
                                AND PROCESS_ENABLED_FLAG='Y';
                                -- get discrete org
                                SELECT 1 INTO l_count_disc FROM MTL_PARAMETERS
                                WHERE ORGANIZATION_ID=P_ORGANIZATION_IDS(l_index)
                                AND PROCESS_ENABLED_FLAG<>'Y';
                                IF l_count=1 and l_count_disc=1 THEN
                                   -- failure condition
                                   -- both falgs can be 1 only if some orgs are process
                                   -- and some orgs are discrete
                                   FND_MESSAGE.SET_NAME('INV','INV_MIXED_ORG_NOT_ALLOWED');--ACTION
                                   FND_MSG_PUB.ADD;
                                   RETURN FALSE;
                                END IF;
                           EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                NULL;
                           END;
                        END IF;
                 ELSIF p_flow_type=2 THEN-- procuring
                 /** INVCONV remove the check for process org
                       BEGIN
                                SELECT 1 INTO l_count FROM MTL_PARAMETERS
                                WHERE ORGANIZATION_ID=P_ORGANIZATION_IDS(l_index)
                                AND PROCESS_ENABLED_FLAG='Y';
                                -- if a record is found then its a failure condition
                                -- process enabled orgs are not supported  for global procuring transaction
                                FND_MESSAGE.SET_NAME('INV','INV_PROCESS_ORG_DISALLOWED');--ACTION
                                FND_MSG_PUB.ADD;
                                RETURN FALSE;
                       EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                NULL;
                                -- success condition
                       END;
                  **/
                  null ;
                 END IF;-- flow type
         END LOOP;
         RETURN TRUE;

END Validate_Inv_Organization_Type;

/*=======================================================================================================*/
  PROCEDURE Create_Sorted_Table(
				X_RETURN_STATUS	OUT NOCOPY	VARCHAR2,
				X_SORTED_TABLE	OUT NOCOPY	TRX_FLOW_LINES_TAB,
				P_START_ORG_ID	IN		NUMBER,
				P_END_ORG_ID	IN		NUMBER,
				P_LINES_TABLE	IN		TRX_FLOW_LINES_TAB
				) IS
l_out_table TRX_FLOW_LINES_TAB;
l_num_recs NUMBER:=p_lines_table.count;
l_line_rec TRX_FLOW_LINE_REC;
BEGIN
	IF g_debug=1 THEN
	   debug('l_num_recs= '||l_num_recs,'Create_Sorted_Table');
	END IF;
	IF l_num_recs=0 THEN
	    FND_MESSAGE.SET_NAME('INV','INV_NO_TRX_FLOW_LINE');
            FND_MSG_PUB.ADD;
            X_RETURN_STATUS:=FND_API.G_RET_STS_ERROR;
	    RETURN ;
	END IF;
	--clear cache
	IF l_out_table.count>0 then
	   l_out_table.delete;
	END IF;
	-- get the first record
	IF l_num_recs=1 THEN
      IF(p_lines_table(1).to_org_id <> p_end_org_id)then
	       X_RETURN_STATUS:=FND_API.G_RET_STS_ERROR;
	       FND_MESSAGE.SET_NAME('INV','INV_NO_START_NODE');
	       FND_MSG_PUB.ADD;
	       RETURN;
      ELSE
	    x_sorted_table:=p_lines_table;
	    X_RETURN_STATUS:=FND_API.G_RET_STS_SUCCESS;
	    IF g_debug=1 THEN
	       debug('Trx flow has only one node'||l_num_recs,'Create_Sorted_Table');
	    END IF;
      END IF;
	    RETURN;
	END IF;
	IF l_num_recs>1 THEN
	   FOR l_index IN 1..l_num_recs
	   LOOP -- search for record with from_org_id=start_org_id
		IF p_lines_table(l_index).from_org_id=p_start_org_id THEN
		   l_out_table(1):=p_lines_table(l_index);
		   EXIT;
		END IF;
	   END LOOP;
	   IF l_out_table.count=0 THEN
	      -- start node not found
	       X_RETURN_STATUS:=FND_API.G_RET_STS_ERROR;
	       FND_MESSAGE.SET_NAME('INV','INV_NO_START_NODE');
	       FND_MSG_PUB.ADD;
	      RETURN;
	   END IF;
	   IF g_debug=1 THEN
	      debug('Start node found'||l_num_recs,'Create_Sorted_Table');
	   END IF;
	END IF;--l_num_recs>1
	-- get the last record
	IF l_num_recs>1 THEN
	   FOR l_index IN 1..l_num_recs
	   LOOP -- search for record with to_org_id=end_org_id
		IF p_lines_table(l_index).to_org_id=p_end_org_id THEN
		   l_out_table(l_num_recs):=p_lines_table(l_index);
		   EXIT;
		END IF;
	   END LOOP;
	   IF l_out_table.count <> 2 THEN
	      -- end node not found
	       X_RETURN_STATUS:=FND_API.G_RET_STS_ERROR;
	       FND_MESSAGE.SET_NAME('INV','INV_INCOMPLETE_FLOW');
	       FND_MSG_PUB.ADD;
	      RETURN;
	   END IF;
	   IF g_debug=1 THEN
	      debug('End node found'||l_num_recs,'Create_Sorted_Table');
	   END IF;
	END IF;--l_num_recs>1
	IF g_debug=1 THEN
	   debug('Start and End nodes found','Create_Sorted_Table');
	END IF;

	-- get intermediate connecting nodes
	IF l_num_recs>2 THEN
		FOR l_index_out IN 2..(l_num_recs-1) -- first and second record already processed
		LOOP
			IF g_debug=1 THEN
			   debug('l_index_out='||l_index_out,'Create_Sorted_Table');
			END IF;
			FOR l_index IN 1..l_num_recs
			LOOP
				IF ( p_lines_table(l_index).from_org_id=l_out_table(l_index_out-1).to_org_id)
				   AND ( p_lines_table(l_index).from_organization_id=l_out_table(l_index_out-1).to_organization_id)
				   THEN
				   l_out_table(l_index_out):=p_lines_table(l_index);
				   EXIT;
				END IF;
			END LOOP;
			IF l_out_table.count <> (l_index_out+1) THEN
			   -- connecting node not found
			    X_RETURN_STATUS:=FND_API.G_RET_STS_ERROR;
			   FND_MESSAGE.SET_NAME('INV','INV_INCOMPLETE_FLOW'); --ACTION SET TOKEN
			   FND_MSG_PUB.ADD;
			   RETURN;
			END IF;
		END LOOP;--l_index_out IN 2..l_num_recs-1
	END IF;
	--
	-- if only two nodes then validated connecting org/organizations
	IF l_num_recs=2 THEN
	   IF ( l_out_table(1).to_org_id <> l_out_table(2).from_org_id )
	      OR ( l_out_table(1).to_organization_id <> l_out_table(2).from_organization_id )
	      THEN
	      IF g_debug=1 THEN
		 debug('Cross validation for org/organizations failed','Create_Sorted_Table');
	      END IF;
	      X_RETURN_STATUS:=FND_API.G_RET_STS_ERROR;
	      FND_MESSAGE.SET_NAME('INV','INV_INCOMPLETE_FLOW'); --ACTION SET TOKEN
	      FND_MSG_PUB.ADD;
	      RETURN;
	   END IF;
	ELSIF l_num_recs>2 THEN -- if more than two nodes then validated connecting org/organizations for last and second last nodes
	  IF ( l_out_table(l_out_table.count-1).to_org_id <> l_out_table(l_out_table.count).from_org_id )
	      OR ( l_out_table(l_out_table.count-1).to_organization_id <> l_out_table(l_out_table.count).from_organization_id )
	      THEN
	      IF g_debug=1 THEN
		 debug('Cross validation for org/organizations failed','Create_Sorted_Table');
	      END IF;
	      X_RETURN_STATUS:=FND_API.G_RET_STS_ERROR;
	      FND_MESSAGE.SET_NAME('INV','INV_INCOMPLETE_FLOW'); --ACTION SET TOKEN
	      FND_MSG_PUB.ADD;
	      RETURN;
	   END IF;
	END IF;

	X_RETURN_STATUS:=FND_API.G_RET_STS_SUCCESS;
	x_sorted_table:=l_out_table;
	IF g_debug=1 THEN
	   debug('Sorted table created','Create_Sorted_Table');
	END IF;
END Create_Sorted_Table;

/*=======================================================================================================*/

FUNCTION Validate_Trx_Flow_Lines(
                                 P_LINES_TAB                    IN INV_TRANSACTION_FLOW_PVT.TRX_FLOW_LINES_TAB,
                                 P_SHIP_FROM_TO_ORGANIZATION_ID IN NUMBER,
                                 P_FLOW_TYPE                    IN NUMBER,
                                 P_START_ORG_ID                 IN NUMBER,
                                 P_END_ORG_ID                   IN NUMBER,
				 P_NEW_ACCOUNTING_FLAG          IN VARCHAR2
                                ) RETURN BOOLEAN IS

l_from_orgs_tab TABLE_OF_NUMBERS;
l_to_orgs_tab TABLE_OF_NUMBERS;
l_org_ids TABLE_OF_NUMBERS;
l_count NUMBER;
l_count1 NUMBER;
l_return_status VARCHAR2(3);
from_org_name varchar2(100);
to_org_name varchar2(100);
l_lines_table TRX_FLOW_LINES_TAB;

BEGIN
         if g_debug=1 then
	    debug('Starting validations for lines','Validate_Trx_Flow_Lines');
	 end if;
	 Create_Sorted_Table(
				X_RETURN_STATUS	=> l_return_status,
				X_SORTED_TABLE	=> l_lines_table,
				P_START_ORG_ID	=> p_start_org_id,
				P_END_ORG_ID	=> p_end_org_id,
				P_LINES_TABLE	=> p_lines_tab
				) ;
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   RETURN FALSE;
	END IF;

   --See that all the organizations are not null
   --except from_organization_id in first line for shipping flow
   --and to_organization_id of last line for Procuring flow

   	IF  P_FLOW_TYPE =1 then
	IF(l_lines_table.count>1)THEN
	 FOR l_index IN 2..l_lines_table.count
         LOOP
	 IF(l_lines_table(l_index).from_organization_id IS NULL)THEN
          FND_MESSAGE.SET_NAME('INV','INV_INVALID_SETUP');
          FND_MSG_PUB.ADD;
          RETURN FALSE;
	 END IF;
	 END LOOP;
        END IF;

	 FOR l_index IN 1..l_lines_table.count
         LOOP

         -- For Bug 4428974
         -- Added condition of P_NEW_ACCOUNTING_FLAG = 'Y' in the IF statement.
         --
	 IF(l_lines_table(l_index).to_organization_id IS NULL) AND P_NEW_ACCOUNTING_FLAG = 'Y' THEN
          FND_MESSAGE.SET_NAME('INV','INV_INVALID_SETUP');
          FND_MSG_PUB.ADD;
          RETURN FALSE;
	 END IF;
	 END LOOP;

       ELSIF P_FLOW_TYPE =2 then


        if g_debug=1 then
	    debug('1.1','Validate_Trx_Flow_Lines');
	 end if;
	 FOR l_index IN 1..l_lines_table.count
         LOOP
	  if g_debug=1 then
	    debug('1.1'||l_index,'Validate_Trx_Flow_Lines');
	 end if;
	 IF(l_lines_table(l_index).from_organization_id IS NULL)THEN
          FND_MESSAGE.SET_NAME('INV','INV_INVALID_SETUP');
          FND_MSG_PUB.ADD;
          RETURN FALSE;
	 END IF;
	 END LOOP;

	 IF(l_lines_table.count>1)THEN
	 FOR l_index IN 1..l_lines_table.count-1
         LOOP
	 IF(l_lines_table(l_index).to_organization_id IS NULL)THEN
          FND_MESSAGE.SET_NAME('INV','INV_INVALID_SETUP');
          FND_MSG_PUB.ADD;
          RETURN FALSE;
	 END IF;
	 END LOOP;
        END IF;

      END IF;


   --
         -- validate to and from operating units
	  if g_debug=1 then
	    debug('VALUE OF START_ORG_ID'||p_start_org_id,'Validate_Trx_Flow_Lines');
	    debug('VALUE OF FROM_ORG_ID'||l_lines_table(1).from_org_id,'Validate_Trx_Flow_Lines');
	 end if;
         IF p_start_org_id <> l_lines_table(1).from_org_id THEN
            -- failure
            FND_MESSAGE.SET_NAME('INV','INV_INVALID_FROM_OU');
            FND_MSG_PUB.ADD;
            RETURN FALSE;
         END IF;
         IF p_end_org_id<> l_lines_table(l_lines_table.count).to_org_id THEN
            -- failure
            FND_MESSAGE.SET_NAME('INV','INV_INVALID_TO_OU');
            FND_MSG_PUB.ADD;
            RETURN FALSE;
         END IF;
         if g_debug=1 then
	    debug('From/To Org validated','Validate_Trx_Flow_Lines');
	 end if;
	 --
         -- validate from/to organizations
         IF p_flow_type=1 THEN
            -- from organization of first line should be equal to ship_from organization
            -- it can be null also
            IF nvl(p_ship_from_to_organization_id,-999)<>nvl(l_lines_table(1).from_organization_id,-999) THEN
               -- failure
               FND_MESSAGE.SET_NAME('INV','INV_INVALID_FROM_ORGANIZATION');
               FND_MSG_PUB.ADD;
               RETURN FALSE;
            END IF;
         ELSIF p_flow_type=2 THEN
               -- to organization of last line should be equal to ship_to organization
               -- it can be null also
               IF nvl(p_ship_from_to_organization_id,-999)<>nvl(l_lines_table(l_lines_table.count).to_organization_id,-999) THEN
                   -- failure
                   FND_MESSAGE.SET_NAME('INV','INV_INVALID_TO_ORGANIZATION');
                   FND_MSG_PUB.ADD;
                   RETURN FALSE;
               END IF;
         END IF;-- flow_type
         if g_debug=1 then
	    debug('From/To Organization validated','Validate_Trx_Flow_Lines');
	 end if;
	 --
         -- all from/to org/organizations should be valid
         FOR l_index IN 1..l_lines_table.count
         LOOP
	       if g_debug=1 then
	    debug('BEFORE VALIDATING OPERATING UNIT','Validate_Trx_Flow_Lines');
	 end if;
                 -- validate orgs
                 IF NOT Validate_Operating_Unit(l_lines_table(l_index).from_org_id) THEN
                        FND_MESSAGE.SET_NAME('INV','INV_INVALID_FROM_OU');
                        FND_MSG_PUB.ADD;
                        RETURN FALSE;
                 END IF;
                 IF NOT Validate_Operating_Unit(l_lines_table(l_index).to_org_id) THEN
                        FND_MESSAGE.SET_NAME('INV','INV_INVALID_TO_OU');
                    FND_MSG_PUB.ADD;
                        RETURN FALSE;
                 END IF;
                 -- validate organizations
                 IF l_index=1 OR l_index=l_lines_table.count THEN -- first or last line organization can be null
                    IF p_flow_type=1 THEN
                       IF l_lines_table(l_index).from_organization_id IS NOT NULL THEN
                          IF NOT Validate_Organization(
                                                       P_ORGANIZATION_ID => l_lines_table(l_index).from_organization_id,
                                                       P_ORG_ID          => l_lines_table(l_index).from_org_id) THEN
                             FND_MESSAGE.SET_NAME('INV','INV_INVALID_FROM_ORGANIZATION');
                             FND_MSG_PUB.ADD;
                             RETURN FALSE;
                           END IF;
		       END IF;
                    ELSIF p_flow_type=2 THEN
                          IF l_lines_table(l_index).to_organization_id IS NOT NULL THEN
                             IF NOT Validate_Organization(
                                                          P_ORGANIZATION_ID => l_lines_table(l_index).to_organization_id,
                                                          P_ORG_ID          => l_lines_table(l_index).to_org_id) THEN
                                FND_MESSAGE.SET_NAME('INV','INV_INVALID_TO_ORGANIZATION');
                                FND_MSG_PUB.ADD;
                                RETURN FALSE;
                             END IF;
                           END IF;
                   END IF;
                 ELSE -- l_index
                   IF NOT Validate_Organization(
                                                P_ORGANIZATION_ID => l_lines_table(l_index).from_organization_id,
                                                P_ORG_ID          => l_lines_table(l_index).from_org_id) THEN
                      FND_MESSAGE.SET_NAME('INV','INV_INVALID_FROM_ORGANIZATION');
                      FND_MSG_PUB.ADD;
                      RETURN FALSE;
                   END IF;
                   IF NOT Validate_Organization(
                                                P_ORGANIZATION_ID => l_lines_table(l_index).to_organization_id,
                                                P_ORG_ID          => l_lines_table(l_index).to_org_id) THEN
                      FND_MESSAGE.SET_NAME('INV','INV_INVALID_TO_ORGANIZATION');
                      FND_MSG_PUB.ADD;
                      RETURN FALSE;
                   END IF;
                 END IF;
         END LOOP;--l_lines_table.count
	 if g_debug=1 then
	    debug('All OUs and Organizations validated','Validate_Trx_Flow_Lines');
	 end if;
        --
        -- no org should come twice in the lines tab
        --
        IF l_from_orgs_tab.count>0 THEN
           l_from_orgs_tab.delete;
        END IF;
        IF l_to_orgs_tab.count>0 THEN
           l_to_orgs_tab.delete;
        END IF;
        --
        FOR l_index IN 1..l_lines_table.count
        LOOP
                IF l_from_orgs_tab.exists(l_lines_table(l_index).from_org_id) THEN
                   -- failure
                   Begin
         		     select name into from_org_name from hr_operating_units
         		     where Organization_id=l_lines_table(l_index).from_org_id;
                   Exception
         		    WHEN NO_DATA_FOUND THEN
         		    NULL;
         		    End;
                   FND_MESSAGE.SET_NAME('INV','INV_DUPLICATE_OU');
		             FND_MESSAGE.SET_TOKEN('FROM_TO','INV_FROM',TRUE);
                   FND_MESSAGE.SET_TOKEN('OU',from_org_name,TRUE);
                   FND_MSG_PUB.ADD;
                   RETURN FALSE;
                ELSE
                   l_from_orgs_tab(l_lines_table(l_index).from_org_id):=1;
                END IF;
                --
                IF l_to_orgs_tab.exists(l_lines_table(l_index).from_org_id) THEN
                   -- failure
                   Begin
		              select name into to_org_name from hr_operating_units
		              where Organization_id=l_lines_table(l_index).to_org_id;
                   Exception
		             WHEN NO_DATA_FOUND THEN
		             NULL;
		             End;
                   FND_MESSAGE.SET_NAME('INV','INV_DUPLICATE_OU');
		             FND_MESSAGE.SET_TOKEN('FROM_TO','INV_TO',TRUE);
                   FND_MESSAGE.SET_TOKEN('OU',to_org_name,TRUE);
                   FND_MSG_PUB.ADD;
                   RETURN FALSE;
                ELSE
                   l_to_orgs_tab(l_lines_table(l_index).from_org_id):=1;
                END IF;
        END LOOP;--tab_count
	if g_debug=1 then
	    debug('All OUs validated for duplication','Validate_Trx_Flow_Lines');
	end if;
	--
	-- Validate Organizationf for Type Process/Discrete
	--
	IF l_org_ids.count>1 THEN
	   l_org_ids.delete;
	END IF;
	-- prepare the org_ids tab
	IF l_lines_table(1).from_organization_id IS NOT NULL THEN
	   l_org_ids(1):=l_lines_table(1).from_organization_id;
	END IF;
	--
	IF l_lines_table(l_lines_table.count).to_organization_id IS NOT NULL THEN
	   l_org_ids(l_lines_table.count+l_org_ids.count):=l_lines_table(l_lines_table.count).to_organization_id;
	END IF;
	--
	FOR l_index IN 2..l_lines_table.count
	LOOP
		l_org_ids(l_org_ids.count+1):=l_lines_table(l_index).from_organization_id;
	END LOOP;
	--
      	IF NOT Validate_Inv_Organization_Type(
                                        P_FLOW_TYPE             => p_flow_type,
                                        P_ORGANIZATION_IDS      => l_org_ids,
                                        P_NEW_ACCOUNTING_FLAG   => p_new_accounting_flag
                                        )
										THEN
	   -- Failure
	   RETURN FALSE;
	END IF;
	if g_debug=1 then
	    debug('All organizations validated for process/discrete type','Validate_Trx_Flow_Lines');
	end if;
	-- for each line IC Relations should be defined
        --
        FOR l_index IN 1..l_lines_table.count
        LOOP
                BEGIN
		         if g_debug=1 then
	                  debug('The value of from_org_id is'||l_lines_table(l_index).from_org_id,'Validate_Trx_Flow_Lines');
			    debug('The value of to_org_id is'||l_lines_table(l_index).to_org_id,'Validate_Trx_Flow_Lines');
	                 end if;
                         SELECT 1 INTO l_count FROM MTL_INTERCOMPANY_PARAMETERS
                         WHERE SHIP_ORGANIZATION_ID=l_lines_table(l_index).from_org_id
                         AND SELL_ORGANIZATION_ID=l_lines_table(l_index).to_org_id
                         AND FLOW_TYPE=p_flow_type;
		         If l_count=1
                          Then
			   If(P_NEW_ACCOUNTING_FLAG ='Y')
         	            Then
                             Begin
			      select 1 into l_count1 from dual where exists
                              (
                               select ship_organization_id from mtl_intercompany_parameters
                               where ship_organization_id=l_lines_table(l_index).from_org_id
                               and sell_organization_id=l_lines_table(l_index).to_org_id
                               and flow_type=p_flow_type
                               and
			       (
                               intercompany_cogs_account_id is null
                               or inventory_accrual_account_id is null
                               or expense_accrual_account_id is null
                               )
                              );
			     EXCEPTION
                             WHEN NO_DATA_FOUND THEN
			     NULL;
			     END;

			    IF(l_count1=1)THEN
			    --failure
			    FND_MESSAGE.SET_NAME('INV','INV_NO_IC_RELATIONS');
                            FND_MSG_PUB.ADD;
                            RETURN FALSE;
			    END IF;
                           END IF;
	                  END IF;



                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  -- failure
		  FND_MESSAGE.SET_NAME('INV','INV_NO_IC_RELATIONS');
                  FND_MSG_PUB.ADD;
                  RETURN FALSE;
                  END;
        END LOOP;--ic relations
	if g_debug=1 then
	    debug('IC Relations validated for all nodes','Validate_Trx_Flow_Lines');
	end if;
        --
	-- All validations passed
        RETURN TRUE;
END Validate_Trx_Flow_Lines;
/*=====================================================================================================*/
 PROCEDURE Txn_Flow_Dff   ( X_RETURN_STATUS OUT NOCOPY   VARCHAR2
                           ,X_MSG_COUNT     OUT NOCOPY   NUMBER
                           ,X_MSG_DATA      OUT NOCOPY   VARCHAR2
                           ,X_ENABLED_SEGS  OUT NOCOPY    inv_lot_sel_attr.lot_sel_attributes_tbl_type
                           ,P_CONTEXT       IN           VARCHAR2
			   ,P_FLEX_NAME     IN           VARCHAR2
                          )
IS
    l_context_r           fnd_dflex.context_r;
    l_contexts_dr         fnd_dflex.contexts_dr;
    l_dflex_r             fnd_dflex.dflex_r;
    l_segments_dr         fnd_dflex.segments_dr;
    l_global_context      BINARY_INTEGER;
    l_nsegments           BINARY_INTEGER;
    l_tbl_index           NUMBER :=0;
BEGIN
  X_RETURN_STATUS := 'S';

if g_debug=1 then
 debug('In the Txn flow_dff','Txn_Flow_Dff');
 end if;

   /*Prepare the DFF definition and context information */

   l_dflex_r.application_id  := 401;
   l_dflex_r.flexfield_name  := P_FLEX_NAME;

   l_context_r.flexfield     := l_dflex_r;
   l_context_r.context_code  := P_CONTEXT;

    /* For a passed context, get all the enabled segments */

    fnd_dflex.get_segments(  CONTEXT => l_context_r
                           , segments => l_segments_dr
                           , enabled_only => TRUE
                          );

    /*From l_segmenst_dr get the number of segments */

    l_nsegments               := l_segments_dr.nsegments;

    --dbms_output.put_line('The value of l_nsegments '||l_segments_dr.nsegments );
if g_debug=1 then
 debug('Before populating the table','Txn_Flow_Dff');
 debug('The value of l_nsegments '||l_segments_dr.nsegments ,'Txn_Flow_Dff');
 end if;

    FOR i IN 1..l_nsegments
    LOOP
       l_tbl_index := to_number(SUBSTR(l_segments_dr.application_column_name(i),INSTR(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9));
       X_ENABLED_SEGS(l_tbl_index).COLUMN_NAME := l_segments_dr.application_column_name(i);
       X_ENABLED_SEGS(l_tbl_index).COLUMN_TYPE := 'VARCHAR2';
       IF  l_segments_dr.is_required(i) THEN
           X_ENABLED_SEGS(l_tbl_index).REQUIRED    := 'TRUE';
       ELSE
           X_ENABLED_SEGS(l_tbl_index).REQUIRED    := 'FALSE';
       END IF;

    END LOOP;

 if g_debug=1 then
  debug('Afetr populating the table','Txn_Flow_Dff');
 end if;

EXCEPTION
   WHEN OTHERS THEN
      X_RETURN_STATUS := 'E';
       fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

END Txn_Flow_Dff;


/*=======================================================================================================*/
FUNCTION Validate_Dff(P_FLEX_NAME          IN   VARCHAR2,
                      P_ATTRIBUTE1         IN   VARCHAR2,
		      P_ATTRIBUTE2         IN   VARCHAR2,
		      P_ATTRIBUTE3         IN   VARCHAR2,
		      P_ATTRIBUTE4         IN   VARCHAR2,
		      P_ATTRIBUTE5         IN   VARCHAR2,
		      P_ATTRIBUTE6         IN   VARCHAR2,
		      P_ATTRIBUTE7         IN   VARCHAR2,
		      P_ATTRIBUTE8         IN   VARCHAR2,
		      P_ATTRIBUTE9         IN   VARCHAR2,
		      P_ATTRIBUTE10        IN   VARCHAR2,
		      P_ATTRIBUTE11        IN   VARCHAR2,
		      P_ATTRIBUTE12        IN   VARCHAR2,
		      P_ATTRIBUTE13        IN   VARCHAR2,
		      P_ATTRIBUTE14        IN   VARCHAR2,
		      P_ATTRIBUTE15        IN   VARCHAR2,
		      P_ATTRIBUTE_CATEGORY IN   VARCHAR2
		      ) RETURN BOOLEAN IS

  l_return_status      varchar2(1);
  l_msg_data           varchar2(2000);
  l_msg_count          number;
  l_ENABLED_SEGS       inv_lot_sel_attr.lot_sel_attributes_tbl_type;
  l_contexts_dr        fnd_dflex.contexts_dr;
  l_context            VARCHAR2(1000);
  l_dflex_r            fnd_dflex.dflex_r;
  l_global_context     BINARY_INTEGER;
  l_tbl_index          number :=0;
  l_loop_index         NUMBER := 0;
  TYPE txn_hdr_dff is  TABLE of VARCHAR2(1000) INDEX BY BINARY_INTEGER;
  l_txn_hdr_dff        txn_hdr_dff;
  l_txn_hdr_attr       txn_hdr_dff;

  USER_ERROR           EXCEPTION;
  ERRORS_RECEIVED      EXCEPTION;
  ERROR_SEGMENT        VARCHAR2(30);
  error_msg            VARCHAR2(5000);
  s                    NUMBER;
  e                    NUMBER;

  L_INDEX            NUMBER;
  L_INDEX1            NUMBER;
  l_check_valid_seg  NUMBER:=0;


BEGIN
 if g_debug=1 then
 debug('In validate Dff','Validate_Dff');
 end if;
     l_txn_hdr_attr(1)  := p_attribute1;
     l_txn_hdr_attr(2)  := p_attribute2;
     l_txn_hdr_attr(3)  := p_attribute3;
     l_txn_hdr_attr(4)  := p_attribute4;
     l_txn_hdr_attr(5)  := p_attribute5;
     l_txn_hdr_attr(6)  := p_attribute6;
     l_txn_hdr_attr(7)  := p_attribute7;
     l_txn_hdr_attr(8)  := p_attribute8;
     l_txn_hdr_attr(9)  := p_attribute9;
     l_txn_hdr_attr(10) := p_attribute10;
     l_txn_hdr_attr(11) := p_attribute11;
     l_txn_hdr_attr(12) := p_attribute12;
     l_txn_hdr_attr(13) := p_attribute13;
     l_txn_hdr_attr(14) := p_attribute14;
     l_txn_hdr_attr(15) := p_attribute15;

  if g_debug=1 then
   debug('After populating the table','Validate_Dff');
  end if;
   l_dflex_r.application_id  := 401;
   l_dflex_r.flexfield_name  := P_FLEX_NAME;

   /* Get all contexts */

   fnd_dflex.get_contexts(flexfield => l_dflex_r, contexts => l_contexts_dr);

    /* From the l_contexts_dr, get the position of the global context */
    l_global_context          := l_contexts_dr.global_context;

    if g_debug=1 then
    debug('before getting  global contexts'||l_global_context,'Validate_Dff');
   end if;
   /* Using the position get the Global context*/
    l_context := l_contexts_dr.context_code(l_global_context);

   if g_debug=1 then
    debug('after getting  global context'||l_context,'Validate_Dff');
   end if;

   /*For the Global context get all the enabled columns */
 if g_debug=1 then
    debug('before call to Txn flow_dff','Validate_Dff');
   end if;
    TXN_FLOW_DFF( X_RETURN_STATUS =>l_return_status
                 ,X_MSG_COUNT     =>l_msg_count
                 ,X_MSG_DATA      =>l_msg_data
                 ,X_ENABLED_SEGS  => l_ENABLED_SEGS
                 ,P_CONTEXT       => l_context
		 ,P_FLEX_NAME     => p_flex_name
                );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN FALSE;
    END IF;

   if g_debug=1 then
    debug('after call to Txn flow_dff','Validate_Dff');
   end if;

    l_loop_index := l_enabled_segs.first;
    while l_loop_index <= l_enabled_segs.last
    loop
         /* Check if the column is required and input column has been populated */
         IF l_enabled_segs(l_loop_index).required ='TRUE' and
            NOT l_txn_hdr_attr.exists(TO_NUMBER(substr(l_enabled_segs(l_loop_index).column_name,
                                                      instr(l_enabled_segs(l_loop_index).column_name,'ATTRIBUTE')+9))) THEN
            FND_MESSAGE.SET_NAME('INV','INV_REQ_SEG_MISS');
	    FND_MESSAGE.SET_TOKEN('SEGMENT',l_enabled_segs(l_loop_index).column_name,TRUE);
            FND_MSG_PUB.ADD;
	    RETURN FALSE;
         END IF;
     if g_debug=1 then
      debug(' The column is '||l_enabled_segs(l_loop_index).column_name,'Validate_Dff');
     end if;

	 l_tbl_index := l_tbl_index +1;
         l_txn_hdr_dff(l_tbl_index) :=l_enabled_segs(l_loop_index).column_name;
         fnd_flex_descval.set_column_value(l_enabled_segs(l_loop_index).column_name,
                                           l_txn_hdr_attr(TO_NUMBER(substr(l_enabled_segs(l_loop_index).column_name,
                                                      instr(l_enabled_segs(l_loop_index).column_name,'ATTRIBUTE')+9)))
                                          );

         l_loop_index := l_enabled_segs.next(l_loop_index);
    end loop;
   if g_debug=1 then
    debug('after validating for global segs','Validate_Dff');
   end if;
     l_enabled_segs.delete;

   /* Call the API to get the segments for the passed Attribute category */

    l_context                 := p_attribute_category;
    fnd_flex_descval.set_context_value(l_context);

    TXN_FLOW_DFF( X_RETURN_STATUS =>l_return_status
                 ,X_MSG_COUNT     =>l_msg_count
                 ,X_MSG_DATA      =>l_msg_data
                 ,X_ENABLED_SEGS  => l_ENABLED_SEGS
                 ,P_CONTEXT       => l_context
		 ,P_FLEX_NAME     => p_flex_name
                );
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN FALSE;
    END IF;
  if g_debug=1 then
    debug(' after 2 call to Txn flow dff','Validate_Dff');
  end if;
    l_loop_index := 0;

    l_loop_index := l_enabled_segs.first;

    while l_loop_index <= l_enabled_segs.last
    loop
         IF l_enabled_segs(l_loop_index).required ='TRUE' and
            NOT l_txn_hdr_attr.exists(TO_NUMBER(substr(l_enabled_segs(l_loop_index).column_name,
                                                      instr(l_enabled_segs(l_loop_index).column_name,'ATTRIBUTE')+9))) THEN
            FND_MESSAGE.SET_NAME('INV','INV_REQ_SEG_MISS');
	    FND_MESSAGE.SET_TOKEN('SEGMENT',l_enabled_segs(l_loop_index).column_name,TRUE);
           FND_MSG_PUB.ADD;
	   RETURN FALSE;
         END IF;
 if g_debug=1 then
    debug(' The column is for context '||l_enabled_segs(l_loop_index).column_name,'Validate_Dff');
    debug(' The l_tbl_index is '||l_tbl_index,'Validate_Dff');
  end if;

         l_tbl_index := l_tbl_index +1;
         l_txn_hdr_dff(l_tbl_index) := l_enabled_segs(l_loop_index).column_name;
         fnd_flex_descval.set_column_value(l_enabled_segs(l_loop_index).column_name,
                                           l_txn_hdr_attr(TO_NUMBER(substr(l_enabled_segs(l_loop_index).column_name,
                                                      instr(l_enabled_segs(l_loop_index).column_name,'ATTRIBUTE')+9)))
                                          );
         l_loop_index := l_enabled_segs.next(l_loop_index);
    end loop;

  if g_debug=1 then
    debug('After validating for user context','Validate_Dff');
  end if;

    l_index := l_txn_hdr_attr.first;
    WHILE l_index <= l_txn_hdr_attr.last
    LOOP
      IF l_txn_hdr_attr(l_index) is not null THEN
        l_index1 := l_txn_hdr_dff.first;

          if g_debug=1 then
            debug('The value of l_index is '||l_index,'Validate_Dff');
            debug('The value of l_index1 is '||l_index1,'Validate_Dff');
          end if;
	while l_index1 <=l_txn_hdr_dff.last
        loop
            if g_debug=1 then
             debug('The column in enabled segment is '||l_txn_hdr_dff(l_index1),'Validate_Dff');
            end if;

           IF to_number(substr(l_txn_hdr_dff(l_index1),
                                instr(l_txn_hdr_dff(l_index1),'ATTRIBUTE')+9)) =l_index THEN
              l_check_valid_seg := 1;
              EXIT;
           END IF;
           l_index1 := l_txn_hdr_dff.next(l_index1);
        end loop;
        IF l_check_valid_seg <>1 THEN
           FND_MESSAGE.SET_NAME('INV','INV_WRONG_SEG_POPULATE');
	   FND_MESSAGE.SET_TOKEN('SEGMENT',l_txn_hdr_attr(l_index),TRUE);
	   FND_MESSAGE.SET_TOKEN('CONTEXT',P_ATTRIBUTE_CATEGORY,TRUE);
           FND_MSG_PUB.ADD;
	   RETURN FALSE;
        END IF;
       end if;
        l_check_valid_seg := 0;
        l_index := l_txn_hdr_attr.next(l_index);
    END LOOP;

   IF fnd_flex_descval.validate_desccols(  appl_short_name => 'INV'
                                         , desc_flex_name  => P_FLEX_NAME
                                         , values_or_ids   => 'I'
                                         , validation_date => SYSDATE
                                        ) THEN
 RETURN TRUE;
 if g_debug=1 then
 debug('all validations successfull','Validate_Dff');
 end if;
   ELSE
     error_segment  := fnd_flex_descval.error_segment;
     RAISE errors_received;
   END IF;

EXCEPTION
    WHEN errors_received THEN
      error_msg        := fnd_flex_descval.error_message;
      s                := 1;
      e                := 200;
      WHILE e < 5001 AND SUBSTR(error_msg, s, e) IS NOT NULL LOOP
       FND_MESSAGE.SET_NAME('INV','INV_FND_GENERIC_MSG');
       FND_MESSAGE.SET_TOKEN('MSG',SUBSTR(error_msg, s, e));
       FND_MSG_PUB.ADD;
        s  := s + 200;
        e  := e + 200;
      END LOOP;
  RETURN FALSE;

END;

/*=======================================================================================================*/

PROCEDURE Create_IC_Transaction_Flow(
                                  X_RETURN_STATUS               OUT     NOCOPY     VARCHAR2,
                                  X_MSG_COUNT                   OUT     NOCOPY     NUMBER,
                                  X_MSG_DATA                    OUT     NOCOPY     VARCHAR2,
                                  P_HEADER_ID                   IN		   NUMBER,
                                  P_COMMIT                      IN                 BOOLEAN DEFAULT FALSE,
                                  P_VALIDATION_LEVEL            IN                 NUMBER,--0=>No Validation,1=>Flow Validation
                                  P_START_ORG_ID                IN                 NUMBER,
                                  P_END_ORG_ID                  IN                 NUMBER,
                                  P_FLOW_TYPE                   IN                 NUMBER,
                                  P_ORGANIZATION_ID             IN                 NUMBER,
                                  P_QUALIFIER_CODE              IN                 NUMBER,
                                  P_QUALIFIER_VALUE_ID          IN                 NUMBER,
                                  P_ASSET_ITEM_PRICING_OPTION   IN                 NUMBER,
                                  P_EXPENSE_ITEM_PRICING_OPTION IN                 NUMBER,
                                  P_START_DATE                  IN                 DATE,
                                  P_END_DATE                    IN                 DATE,
                                  P_NEW_ACCOUNTING_FLAG         IN                 VARCHAR2,
                                  P_ATTRIBUTE_CATEGORY          IN                 VARCHAR2,
                                  P_ATTRIBUTE1                  IN                 VARCHAR2,
                                  P_ATTRIBUTE2                  IN                 VARCHAR2,
                                  P_ATTRIBUTE3                  IN                 VARCHAR2,
                                  P_ATTRIBUTE4                  IN                 VARCHAR2,
                                  P_ATTRIBUTE5                  IN                 VARCHAR2,
                                  P_ATTRIBUTE6                  IN                 VARCHAR2,
                                  P_ATTRIBUTE7                  IN                 VARCHAR2,
                                  P_ATTRIBUTE8                  IN                 VARCHAR2,
                                  P_ATTRIBUTE9                  IN                 VARCHAR2,
                                  P_ATTRIBUTE10                 IN                 VARCHAR2,
                                  P_ATTRIBUTE11                 IN                 VARCHAR2,
                                  P_ATTRIBUTE12                 IN                 VARCHAR2,
                                  P_ATTRIBUTE13                 IN                 VARCHAR2,
                                  P_ATTRIBUTE14                 IN                 VARCHAR2,
                                  P_ATTRIBUTE15                 IN                 VARCHAR2,
                                  P_REF_DATE                    IN                 DATE,
                                  P_LINES_TAB                   IN                 INV_TRANSACTION_FLOW_PVT.TRX_FLOW_LINES_TAB
                                  ) IS
l_row_id NUMBER;
l_header_id NUMBER;
inv_j_installed BOOLEAN;
po_j_installed BOOLEAN;
costing_j_installed BOOLEAN;
om_j_installed BOOLEAN;

BEGIN
         SAVEPOINT  CREATE_IC_TRX_FLOW_SP;
	 if g_debug=1 then
	    debug('Inside Create_IC_Transaction_Flow','Create_IC_Transaction_Flow');
	 end if;
	 x_return_status:=FND_API.G_RET_STS_SUCCESS;

	 --Bug 3439577 fix. Inline branching checks
	 --for inventory
	 If (inv_control.get_current_release_level >= INV_Release.Get_J_RELEASE_LEVEL) Then
	    INV_J_INSTALLED :=TRUE;
	    if g_debug=1 then
		      debug('INV J Installed','Create_IC_Transaction_Flow');
	    end if;
	  Else
	    INV_J_INSTALLED :=FALSE;
	    if g_debug=1 then
	       debug('INV J not Installed','Create_IC_Transaction_Flow');
	    end if;
	 End If;

	 --for costing
	 If (CST_VersionCtrl_GRP.GET_CURRENT_RELEASE_LEVEL >=CST_Release_GRP.GET_J_RELEASE_LEVEL )
	   Then
	    COSTING_J_INSTALLED :=TRUE;
	    if g_debug=1 then
	       debug('CST J Installed','Create_IC_Transaction_Flow');
	    end if;
	  Else
	    COSTING_J_INSTALLED :=FALSE;
	    if g_debug=1 then
	       debug('CST J not Installed','Create_IC_Transaction_Flow');
	    end if;
	 End If;

	 --for OM
	 If (OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' )
	   Then
	    OM_J_INSTALLED :=TRUE;
	    if g_debug=1 then
	       debug('OM J Installed','Create_IC_Transaction_Flow');
	    end if;
	  Else
	    OM_J_INSTALLED :=FALSE;
	    if g_debug=1 then
	       debug('OM J not Installed','Create_IC_Transaction_Flow');
	    end if;
	 End IF;

	 --for PO
	 If (PO_CODE_RELEASE_GRP.Current_Release >= PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J) THEN
	    PO_J_INSTALLED :=TRUE;
	    if g_debug=1 then
	       debug('PO J Installed','Create_IC_Transaction_Flow');
	    end if;
	  Else
	    PO_J_INSTALLED :=FALSE;
	    if g_debug=1 then
	       debug('PO J not Installed','Create_IC_Transaction_Flow');
	    end if;
	 End If;

	 --Bug 3439577 fix. Inline branching checks

   	 -- validate the input parameters first
          IF p_validation_level=1 THEN
	        if g_debug=1 then
		   debug('Validation level is 1 = full','Create_IC_Transaction_Flow');
	        end if;

                -- validate operating units
                IF NOT Validate_Operating_Unit(p_start_org_id) THEN
                   FND_MESSAGE.SET_NAME('INV','INV_INVALID_START_ORG');
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
                --
                IF NOT Validate_Operating_Unit(p_end_org_id) THEN
                   FND_MESSAGE.SET_NAME('INV','INV_INVALID_END_ORG');
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
		if g_debug=1 then
		   debug('Start/End OU validated','Create_IC_Transaction_Flow');
	        end if;
                -- Validate Flow Type
                IF p_flow_type NOT IN (1,2) THEN
                   FND_MESSAGE.SET_NAME('INV','INV_INVALID_TRX_FLOW_TYPE');
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_ERROR;
		   --Bug 3439577 fix. Inline branching checks
		   --For Procuring Flow with new accounting (we do not	support old accounting for this type),
		   --you need INV J and Costing J and PO J
		   --For Shipping Flow with new accounting, you need INV J and Costing J and OM J.
		   --Shipping Flow with old accounting needs to be
		   --supported regardless of what patchset of Costing and INV is present
		 ELSIF p_flow_type = 1 THEN --shipping
		   IF p_new_accounting_flag IN ('Y','y')
		     AND NOT(om_j_installed AND inv_j_installed AND costing_j_installed) THEN
		      FND_MESSAGE.SET_NAME('INV','INV_NO_NEW_ACCT_FLOW');
		      FND_MSG_PUB.ADD;
		      RAISE FND_API.G_EXC_ERROR;
		   END IF;
		 ELSIF p_flow_type = 2 THEN --procuring
		   IF NOT(po_j_installed AND inv_j_installed AND costing_j_installed) then
		      FND_MESSAGE.SET_NAME('INV','INV_PROCURING_FLOW_NOT_ALLOWED');
		      FND_MSG_PUB.ADD;
		      RAISE FND_API.G_EXC_ERROR;
		   END IF;
		END IF;
		-- validate for single ou setup
		IF p_start_org_id=p_end_org_id THEN
		   IF p_flow_type<> 1 THEN
		      FND_MESSAGE.SET_NAME('INV','INV_INVALID_TRX_FLOW_TYPE');
                      FND_MSG_PUB.ADD;
                      RAISE FND_API.G_EXC_ERROR;
		   END IF;
		END IF;
		if g_debug=1 then
		   debug('Flow type validated','Create_IC_Transaction_Flow');
	        end if;
                -- Validate Organization
                IF p_flow_type=1 AND p_organization_id IS NOT NULL THEN
                   IF NOT Validate_Organization(p_organization_id,p_start_org_id) THEN
                          FND_MESSAGE.SET_NAME('INV','INV_INVALID_DOC_ORGANIZATION');
                          FND_MSG_PUB.ADD;
                          RAISE FND_API.G_EXC_ERROR;
                   END IF;
                ELSIF p_flow_type=2 AND p_organization_id IS NOT NULL THEN
                   IF NOT Validate_Organization(p_organization_id,p_end_org_id) THEN
                          FND_MESSAGE.SET_NAME('INV','INV_INVALID_DOC_ORGANIZATION');
                          FND_MSG_PUB.ADD;
                          RAISE FND_API.G_EXC_ERROR;
                   END IF;
                END IF;
		if g_debug=1 then
		   debug('From/To Organization validated','Create_IC_Transaction_Flow');
	        end if;
                -- Validate Qualifier Code
                IF NOT Validate_Qualifier_Code(p_qualifier_code) THEN
                   FND_MESSAGE.SET_NAME('INV','INV_INVALID_QUALIFIER');
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
                -- Validate Qualifier Value
                IF NOT Validate_Qualifier_Value(p_qualifier_code,p_qualifier_value_id,p_flow_type) THEN
                   FND_MESSAGE.SET_NAME('INV','INV_INVALID_QUALIFIER_VALUE');
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
		if g_debug=1 then
		   debug('Qualifier Code and Value validated','Create_IC_Transaction_Flow');
	        end if;
                -- validate pricing options
                IF p_flow_type=1 THEN
                   IF p_asset_item_pricing_option IS NOT NULL OR p_expense_item_pricing_option IS NOT NULL THEN
                          FND_MESSAGE.SET_NAME('INV','INV_INVALID_PRICING_OPTION');
                          FND_MSG_PUB.ADD;
                          RAISE FND_API.G_EXC_ERROR;
                   END IF;
                ELSE
                   IF p_asset_item_pricing_option NOT IN(1,2) OR p_expense_item_pricing_option NOT IN (1,2) THEN
                      FND_MESSAGE.SET_NAME('INV','INV_INVALID_PRICING_OPTION');
                      FND_MSG_PUB.ADD;
                      RAISE FND_API.G_EXC_ERROR;
                    END IF;
		END IF;
		if g_debug=1 then
		   debug('Asset/Expense Item pricing options validated','Create_IC_Transaction_Flow');
	        end if;
		--
         -- set warning if gap will be created with this transaction flow
         --
         IF New_Gap_Created(
			       P_START_ORG_ID       => p_start_org_id,
                               P_END_ORG_ID         => p_end_org_id,
                               P_FLOW_TYPE          => p_flow_type,
                               P_ORGANIZATION_ID    => p_organization_id,
                               P_QUALIFIER_CODE     => p_qualifier_code,
                               P_QUALIFIER_VALUE_ID => p_qualifier_value_id,
                               P_START_DATE         => p_start_date,
                               P_END_DATE           => p_end_date,
                               P_REF_DATE           => p_ref_date
			     )THEN
	 NULL; -- nothing to do message is already set in the called procedure
	 END IF;
	 if g_debug=1 then
	    debug('New gap creation validated','Create_IC_Transaction_Flow');
	 end if;

         END IF; -- validation level=1
         -- do all necessary validations before inserting
         -- Validate New Accounting Flag
         IF NOT Validate_New_Accounting_Flag(
                                              P_START_ORG_ID        => p_start_org_id,
					      P_END_ORG_ID          => p_end_org_id,
					      P_FLOW_TYPE           => p_flow_type,
                                              P_NEW_ACCOUNTING_FLAG => p_new_accounting_flag,
                                              P_NUM_LINES           => p_lines_tab.count
                                             )
                                             THEN
                FND_MESSAGE.SET_NAME('INV','INV_INVALID_NEW_ACCT_FLAG');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
         END IF;
	 if g_debug=1 then
	    debug('New Accounting Flag validated','Create_IC_Transaction_Flow');
	 end if;
         --
         -- Validate Header
         --
         /*IF NOT INV_TRANSACTION_FLOW_PVT.Validate_Header(
                                                        P_HEADER_ID             => p_header_id,
							P_START_ORG_ID          => p_start_org_id,
                                                        P_END_ORG_ID            => p_end_org_id,
                                                        P_FLOW_TYPE             => p_flow_type,
                                                        P_ORGANIZATION_ID       => p_organization_id,
                                                        P_QUALIFIER_CODE        => p_qualifier_code,
                                                        P_QUALIFIER_VALUE_ID    => p_qualifier_value_id,
                                                        P_START_DATE            => p_start_date,
                                                        P_END_DATE              => p_end_date
                                                 )
                                                 THEN
                RAISE FND_API.G_EXC_ERROR;
         END IF;
	 if g_debug=1 then
	    debug('Header validated for duplicate','Create_IC_Transaction_Flow');
	 end if;
         --
         -- Validate Start Date*/
         --
         IF NOT INV_TRANSACTION_FLOW_PVT.Validate_Start_Date(
                                                        P_HEADER_ID             => p_header_id,
							P_START_ORG_ID          => p_start_org_id,
                                                        P_END_ORG_ID            => p_end_org_id,
                                                        P_FLOW_TYPE             => p_flow_type,
                                                        P_ORGANIZATION_ID       => p_organization_id,
                                                        P_QUALIFIER_CODE        => p_qualifier_code,
                                                        P_QUALIFIER_VALUE_ID    => p_qualifier_value_id,
                                                        P_START_DATE            => p_start_date,
                                                        P_REF_DATE              => p_ref_date
                                                        )
                                                THEN
                RAISE FND_API.G_EXC_ERROR;
         END IF;
	 if g_debug=1 then
            debug('Start date validated','Create_IC_Transaction_Flow');
	 end if;
         --
         -- Validate End Date
         --
         IF NOT INV_TRANSACTION_FLOW_PVT.Validate_End_Date(
	                                                P_HEADER_ID             => p_header_id,
                                                        P_START_ORG_ID          => p_start_org_id,
                                                        P_END_ORG_ID            => p_end_org_id,
                                                        P_FLOW_TYPE             => p_flow_type,
                                                        P_ORGANIZATION_ID       => p_organization_id,
                                                        P_QUALIFIER_CODE        => p_qualifier_code,
                                                        P_QUALIFIER_VALUE_ID    => p_qualifier_value_id,
                                                        P_START_DATE            => p_start_date,
                                                        P_END_DATE              => p_end_date,
							P_REF_DATE		=> p_ref_date
                                                        )
                                                THEN
         RAISE FND_API.G_EXC_ERROR;
         END IF;
	 if g_debug=1 then
	    debug('End date validated','Create_IC_Transaction_Flow');
	 end if;

         -- Before inserting header validate the lines also
         -- validate lines only if multi ou setup
	 IF p_start_org_id <> p_end_org_id THEN
	    IF NOT Validate_Trx_Flow_Lines(
                                         P_LINES_TAB                    => p_lines_tab,
                                         P_SHIP_FROM_TO_ORGANIZATION_ID => p_organization_id,
                                         P_FLOW_TYPE                    => p_flow_type,
                                         P_START_ORG_ID                 => p_start_org_id,
                                         P_END_ORG_ID                   => p_end_org_id,
					 P_NEW_ACCOUNTING_FLAG          => p_new_accounting_flag
                                         )
                                         THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
	 ELSE
	    -- nodes cannot be created for single ou setups
	    IF p_lines_tab.count>0 THEN
	       FND_MESSAGE.SET_NAME('INV','INV_TRX_NODE_NOT_ALLOWED');
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
	 END IF;
	 if g_debug=1 then
	    debug('All lines validated','Create_IC_Transaction_Flow');
	 end if;

	 IF P_VALIDATION_LEVEL =1  THEN

    --
	 --Validate the flex columns for header
	 --
        IF NOT Validate_Dff( P_FLEX_NAME          => 'MTL_TXN_FLOW_HEADERS_DFF',
                             P_ATTRIBUTE1         =>  p_attribute1,
		             P_ATTRIBUTE2         =>  p_attribute2,
		             P_ATTRIBUTE3         =>  p_attribute3,
			     P_ATTRIBUTE4         =>  p_attribute4,
		             P_ATTRIBUTE5         =>  p_attribute5,
		             P_ATTRIBUTE6         =>  p_attribute6,
		             P_ATTRIBUTE7         =>  p_attribute7,
		             P_ATTRIBUTE8         =>  p_attribute8,
		             P_ATTRIBUTE9         =>  p_attribute9,
		             P_ATTRIBUTE10        =>  p_attribute10,
		             P_ATTRIBUTE11        =>  p_attribute11,
		             P_ATTRIBUTE12        =>  p_attribute12,
		             P_ATTRIBUTE13        =>  p_attribute13,
		             P_ATTRIBUTE14        =>  p_attribute14,
		             P_ATTRIBUTE15        =>  p_attribute15,
		             P_ATTRIBUTE_CATEGORY =>  p_attribute_category
			    ) THEN
	 RAISE FND_API.G_EXC_ERROR;
         END IF;
	 if g_debug=1 then
	    debug('attribute columns for header validated','Create_IC_Transaction_Flow');
	 end if;

	 --
	 --Validate the flex columns for lines
	 --
	 FOR l_index IN 1..p_lines_tab.count
         LOOP
             IF NOT Validate_Dff(    P_FLEX_NAME          => 'MTL_TXN_FLOW_LINES_DFF',
				     P_ATTRIBUTE1         =>  p_lines_tab(l_index).Attribute1,
				     P_ATTRIBUTE2         =>  p_lines_tab(l_index).Attribute2,
				     P_ATTRIBUTE3         =>  p_lines_tab(l_index).Attribute3,
				     P_ATTRIBUTE4         =>  p_lines_tab(l_index).Attribute4,
				     P_ATTRIBUTE5         =>  p_lines_tab(l_index).Attribute5,
				     P_ATTRIBUTE6         =>  p_lines_tab(l_index).Attribute6,
				     P_ATTRIBUTE7         =>  p_lines_tab(l_index).Attribute7,
				     P_ATTRIBUTE8         =>  p_lines_tab(l_index).Attribute8,
				     P_ATTRIBUTE9         =>  p_lines_tab(l_index).Attribute9,
				     P_ATTRIBUTE10        =>  p_lines_tab(l_index).Attribute10,
				     P_ATTRIBUTE11        =>  p_lines_tab(l_index).Attribute11,
				     P_ATTRIBUTE12        =>  p_lines_tab(l_index).Attribute12,
				     P_ATTRIBUTE13        =>  p_lines_tab(l_index).Attribute13,
				     P_ATTRIBUTE14        =>  p_lines_tab(l_index).Attribute14,
				     P_ATTRIBUTE15        =>  p_lines_tab(l_index).Attribute15,
				     P_ATTRIBUTE_CATEGORY =>  p_lines_tab(l_index).Attribute_Category
			    ) THEN
	 RAISE FND_API.G_EXC_ERROR;
         END IF;

	 END LOOP;
	 if g_debug=1 then
	    debug('attribute columns for lines validated','Create_IC_Transaction_Flow');
	 end if;

	 END IF;
         --
         -- All data is validated can be inserted to tables now
         --
         INV_TRANSACTION_FLOW_PVT.INSERT_TRX_FLOW_HEADER(
                                                        P_HEADER_ID                     =>      p_header_id,
                                                        P_START_ORG_ID                  =>      P_START_ORG_ID,
                                                        P_END_ORG_ID                    =>      P_END_ORG_ID,
                                                        P_FLOW_TYPE                     =>      P_FLOW_TYPE,
                                                        P_ORGANIZATION_ID               =>      P_ORGANIZATION_ID,
                                                        P_QUALIFIER_CODE                =>      P_QUALIFIER_CODE,
                                                        P_QUALIFIER_VALUE_ID            =>      P_QUALIFIER_VALUE_ID,
                                                        P_ASSET_ITEM_PRICING_OPTION     =>      P_ASSET_ITEM_PRICING_OPTION,
                                                        P_EXPENSE_ITEM_PRICING_OPTION   =>      P_EXPENSE_ITEM_PRICING_OPTION,
                                                        P_START_DATE                    =>      P_START_DATE,
                                                        P_END_DATE                      =>      P_END_DATE,
                                                        P_NEW_ACCOUNTING_FLAG           =>      P_NEW_ACCOUNTING_FLAG,
                                                        P_CREATION_DATE                 =>      SYSDATE,
                                                        P_CREATED_BY                    =>      FND_GLOBAL.USER_ID,
                                                        P_LAST_UPDATED_BY               =>      FND_GLOBAL.USER_ID,
                                                        P_LAST_UPDATE_DATE              =>      SYSDATE,
                                                        P_LAST_UPDATE_LOGIN             =>      FND_GLOBAL.LOGIN_ID,
                                                        P_ATTRIBUTE_CATEGORY            =>      P_ATTRIBUTE_CATEGORY,
                                                        P_ATTRIBUTE1                    =>      P_ATTRIBUTE1,
                                                        P_ATTRIBUTE2                    =>      P_ATTRIBUTE2,
                                                        P_ATTRIBUTE3                    =>      P_ATTRIBUTE3,
                                                        P_ATTRIBUTE4                    =>      P_ATTRIBUTE4,
                                                        P_ATTRIBUTE5                    =>      P_ATTRIBUTE5,
                                                        P_ATTRIBUTE6                    =>      P_ATTRIBUTE6,
                                                        P_ATTRIBUTE7                    =>      P_ATTRIBUTE7,
                                                        P_ATTRIBUTE8                    =>      P_ATTRIBUTE8,
                                                        P_ATTRIBUTE9                    =>      P_ATTRIBUTE9,
                                                        P_ATTRIBUTE10                   =>      P_ATTRIBUTE10,
                                                        P_ATTRIBUTE11                   =>      P_ATTRIBUTE11,
                                                        P_ATTRIBUTE12                   =>      P_ATTRIBUTE12,
                                                        P_ATTRIBUTE13                   =>      P_ATTRIBUTE13,
                                                        P_ATTRIBUTE14                   =>      P_ATTRIBUTE14,
                                                        P_ATTRIBUTE15                   =>      P_ATTRIBUTE15
                                                );
         if g_debug=1 then
	    debug('Header inserted','Create_IC_Transaction_Flow');
	 end if;
	 -- insert all the lines
         FOR l_index IN 1..p_lines_tab.count
         LOOP
                 INV_TRANSACTION_FLOW_PVT.INSERT_TRX_FLOW_LINES(
                                                        P_Header_Id                     => p_header_id,
                                                        P_Line_Number                   => p_lines_tab(l_index).line_number,
                                                        P_From_Org_Id                   => p_lines_tab(l_index).from_org_id,
                                                        P_From_Organization_Id          => p_lines_tab(l_index).from_organization_id,
                                                        P_To_Org_Id                     => p_lines_tab(l_index).to_org_id,
                                                        P_To_Organization_Id            => p_lines_tab(l_index).to_organization_id,
                                                        P_Last_Updated_By               => FND_GLOBAL.USER_ID,
                                                        P_Last_Update_Date              => SYSDATE,
                                                        P_Creation_Date                 => SYSDATE,
                                                        P_Created_By                    => FND_GLOBAL.USER_ID,
                                                        P_Last_Update_Login             => FND_GLOBAL.LOGIN_ID,
                                                        P_Attribute_Category            => p_lines_tab(l_index).Attribute_Category,
                                                        P_Attribute1                    => p_lines_tab(l_index).Attribute1,
                                                        P_Attribute2                    => p_lines_tab(l_index).Attribute2,
                                                        P_Attribute3                    => p_lines_tab(l_index).Attribute3,
                                                        P_Attribute4                    => p_lines_tab(l_index).Attribute4,
                                                        P_Attribute5                    => p_lines_tab(l_index).Attribute5,
                                                        P_Attribute6                    => p_lines_tab(l_index).Attribute6,
                                                        P_Attribute7                    => p_lines_tab(l_index).Attribute7,
                                                        P_Attribute8                    => p_lines_tab(l_index).Attribute8,
                                                        P_Attribute9                    => p_lines_tab(l_index).Attribute9,
                                                        P_Attribute10                   => p_lines_tab(l_index).Attribute10,
                                                        P_Attribute11                   => p_lines_tab(l_index).Attribute11,
                                                        P_Attribute12                   => p_lines_tab(l_index).Attribute12,
                                                        P_Attribute13                   => p_lines_tab(l_index).Attribute13,
                                                        P_Attribute14                   => p_lines_tab(l_index).Attribute14,
                                                        P_Attribute15                   => p_lines_tab(l_index).Attribute15
                                                        );
         END LOOP;
         if g_debug=1 then
	    debug('All lines inserted','Create_IC_Transaction_Flow');
	 end if;
         -- commit the changes if required by caller
         IF p_commit THEN
            COMMIT;
         END IF;

EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
                  x_return_status:=FND_API.G_RET_STS_ERROR;
                  ROLLBACK TO CREATE_IC_TRX_FLOW_SP;
		  FND_MSG_PUB.COUNT_AND_GET(
                                        P_ENCODED=>'T',
                                        P_COUNT=>X_MSG_COUNT,
                                        P_DATA=>X_MSG_DATA);
         WHEN OTHERS THEN
                  x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
		  ROLLBACK TO CREATE_IC_TRX_FLOW_SP;
		  FND_MSG_PUB.COUNT_AND_GET(
                                        P_ENCODED=>'T',
                                        P_COUNT=>X_MSG_COUNT,
                                        P_DATA=>X_MSG_DATA);
END Create_IC_Transaction_Flow;

/*=======================================================================================================*/

PROCEDURE Update_IC_Transaction_Flow(
				    X_RETURN_STATUS	   OUT NOCOPY	VARCHAR2,
				    X_MSG_COUNT		   OUT NOCOPY	NUMBER,
				    X_MSG_DATA		   OUT NOCOPY	VARCHAR2,
				    P_COMMIT		   IN		BOOLEAN DEFAULT FALSE,
				    P_HEADER_ID		   IN		NUMBER,
				    P_START_DATE	   IN		DATE,
				    P_END_DATE		   IN		DATE,
				    P_REF_DATE		   IN		DATE,
				    P_ATTRIBUTE_CATEGORY   IN		VARCHAR2,
				    P_ATTRIBUTE1	   IN		VARCHAR2,
                                    P_ATTRIBUTE2	   IN		VARCHAR2,
				    P_ATTRIBUTE3	   IN		VARCHAR2,
                                    P_ATTRIBUTE4	   IN		VARCHAR2,
				    P_ATTRIBUTE5	   IN		VARCHAR2,
                                    P_ATTRIBUTE6	   IN		VARCHAR2,
				    P_ATTRIBUTE7	   IN		VARCHAR2,
                                    P_ATTRIBUTE8	   IN		VARCHAR2,
				    P_ATTRIBUTE9	   IN		VARCHAR2,
                                    P_ATTRIBUTE10	   IN		VARCHAR2,
				    P_ATTRIBUTE11	   IN		VARCHAR2,
                                    P_ATTRIBUTE12          IN		VARCHAR2,
				    P_ATTRIBUTE13	   IN		VARCHAR2,
				    P_ATTRIBUTE14	   IN		VARCHAR2,
                                    P_ATTRIBUTE15          IN		VARCHAR2,
				    P_LINES_TAB            IN           INV_TRANSACTION_FLOW_PVT.TRX_FLOW_LINES_TAB
				    ) IS



l_start_org_id NUMBER;
l_end_org_id NUMBER;
l_flow_type NUMBER;
l_organization_id NUMBER;
l_qualifier_code NUMBER;
l_qualifier_value_id NUMBER;
l_start_date DATE;
l_end_date   DATE;
l_updated_start_date DATE;
l_updated_end_date DATE;
l_from_org_id NUMBER;
l_from_organization_id NUMBER;
l_to_org_id   NUMBER;
l_to_organization_id NUMBER;
BEGIN
	 if g_debug=1 then
	      debug('Starting Update_IC_Transaction_Flow','Update_IC_Transaction_Flow');
	   end if;
	   if g_debug=1 then
	      debug('p_start_date='||p_start_date,'Update_IC_Transaction_Flow');
	      debug('p_end_date='||p_end_date,'Update_IC_Transaction_Flow');
	      debug('p_ref_date='||p_ref_date,'Update_IC_Transaction_Flow');
	   end if;
	SAVEPOINT UPDATE_IC_TRX_FLOW_SP;
	x_return_status:=FND_API.G_RET_STS_SUCCESS;
	-- accuire lock for header
	BEGIN
	   SELECT START_ORG_ID,END_ORG_ID,FLOW_TYPE,ORGANIZATION_ID,
	          QUALIFIER_CODE,QUALIFIER_VALUE_ID,START_DATE,END_DATE
	   INTO l_start_org_id,l_end_org_id,l_flow_type,l_organization_id,
	        l_qualifier_code,l_qualifier_value_id,l_start_date,l_end_date
	   FROM MTL_TRANSACTION_FLOW_HEADERS
	   WHERE HEADER_ID=P_HEADER_ID
	   FOR UPDATE OF START_DATE,END_DATE NOWAIT;
	   if g_debug=1 then
	      debug('Lock accuired for header','Update_IC_Transaction_Flow');
	   end if;
	EXCEPTION
	   WHEN OTHERS THEN
	   -- unable to accuire lock for update
	   -- ACTION
	    if g_debug=1 then
	      debug('Failed to accuire lock for header','Update_IC_Transaction_Flow');
	   end if;
	   FND_MESSAGE.SET_NAME('INV','INV_LOCK_FAILED');
	   FND_MSG_PUB.ADD;
	   RAISE FND_API.G_EXC_ERROR;
	END;

	-- accuire lock for lines
	BEGIN
	   SELECT FROM_ORG_ID,FROM_ORGANIZATION_ID,TO_ORG_ID,TO_ORGANIZATION_ID
	   INTO l_from_org_id,l_from_organization_id,l_to_org_id,l_to_organization_id
	   FROM MTL_TRANSACTION_FLOW_LINES
	   WHERE HEADER_ID=P_HEADER_ID
	   FOR UPDATE NOWAIT;
	   if g_debug=1 then
	      debug('Lock accuired for lines','Update_IC_Transaction_Flow');
	   end if;
	EXCEPTION
	   WHEN OTHERS THEN
	   -- unable to accuire lock for update
	   -- ACTION
	    if g_debug=1 then
	      debug('Failed to accuire lock for lines','Update_IC_Transaction_Flow');
	   end if;
	   FND_MESSAGE.SET_NAME('INV','INV_LOCK_FAILED');
	   FND_MSG_PUB.ADD;
	   RAISE FND_API.G_EXC_ERROR;
	END;
	IF p_start_date <> l_start_date THEN
	   -- do the validation
	   IF NOT INV_TRANSACTION_FLOW_PVT.Validate_Start_Date(
							P_HEADER_ID             => p_header_id,
							P_START_ORG_ID          => l_start_org_id,
							P_END_ORG_ID            => l_end_org_id,
							P_FLOW_TYPE             => l_flow_type,
							P_ORGANIZATION_ID       => l_organization_id,
							P_QUALIFIER_CODE        => l_qualifier_code,
							P_QUALIFIER_VALUE_ID    => l_qualifier_value_id,
							P_START_DATE            => p_start_date,
							P_REF_DATE              => p_ref_date
					)
				     THEN
	         RAISE FND_API.G_EXC_ERROR;
	    END IF;
	END IF;

	IF nvl(p_end_date,sysdate) <> nvl(l_end_date,sysdate) THEN
	   -- do the validations
           IF NOT INV_TRANSACTION_FLOW_PVT.Validate_End_Date(
	                                                P_HEADER_ID             => p_header_id,
                                                        P_START_ORG_ID          => l_start_org_id,
                                                        P_END_ORG_ID            => l_end_org_id,
                                                        P_FLOW_TYPE             => l_flow_type,
                                                        P_ORGANIZATION_ID       => l_organization_id,
                                                        P_QUALIFIER_CODE        => l_qualifier_code,
                                                        P_QUALIFIER_VALUE_ID    => l_qualifier_value_id,
                                                        P_START_DATE            => p_start_date,
                                                        P_END_DATE              => p_end_date,
							P_REF_DATE		=> p_ref_date
                                                        )
                                                THEN
	      RAISE FND_API.G_EXC_ERROR;
          END IF;
	END IF;
       --
       --validate the attributes for the header before update

       /*IF NOT Validate_Dff  (        P_FLEX_NAME          => 'MTL_TXN_FLOW_HEADERS_DFF',
				     P_ATTRIBUTE1         =>  p_attribute1,
				     P_ATTRIBUTE2         =>  p_attribute2,
				     P_ATTRIBUTE3         =>  p_attribute3,
				     P_ATTRIBUTE4         =>  p_attribute4,
				     P_ATTRIBUTE5         =>  p_attribute5,
				     P_ATTRIBUTE6         =>  p_attribute6,
				     P_ATTRIBUTE7         =>  p_attribute7,
				     P_ATTRIBUTE8         =>  p_attribute8,
				     P_ATTRIBUTE9         =>  p_attribute9,
				     P_ATTRIBUTE10        =>  p_attribute10,
				     P_ATTRIBUTE11        =>  p_attribute11,
				     P_ATTRIBUTE12        =>  p_attribute12,
				     P_ATTRIBUTE13        =>  p_attribute13,
				     P_ATTRIBUTE14        =>  p_attribute14,
				     P_ATTRIBUTE15        =>  p_attribute15,
				     P_ATTRIBUTE_CATEGORY =>  p_attribute_category
			    ) THEN
	 RAISE FND_API.G_EXC_ERROR;
         END IF;
	 if g_debug=1 then
	    debug('attribute columns for header validated','Update_IC_Transaction_Flow');
	 end if;

	 --
	 --Validate the flex columns for lines
	 --
	 FOR l_index IN 1..p_lines_tab.count
         LOOP
             IF NOT Validate_Dff(    P_FLEX_NAME          => 'MTL_TXN_FLOW_LINES_DFF',
				     P_ATTRIBUTE1         =>  p_lines_tab(l_index).Attribute1,
				     P_ATTRIBUTE2         =>  p_lines_tab(l_index).Attribute2,
				     P_ATTRIBUTE3         =>  p_lines_tab(l_index).Attribute3,
				     P_ATTRIBUTE4         =>  p_lines_tab(l_index).Attribute4,
				     P_ATTRIBUTE5         =>  p_lines_tab(l_index).Attribute5,
				     P_ATTRIBUTE6         =>  p_lines_tab(l_index).Attribute6,
				     P_ATTRIBUTE7         =>  p_lines_tab(l_index).Attribute7,
				     P_ATTRIBUTE8         =>  p_lines_tab(l_index).Attribute8,
				     P_ATTRIBUTE9         =>  p_lines_tab(l_index).Attribute9,
				     P_ATTRIBUTE10        =>  p_lines_tab(l_index).Attribute10,
				     P_ATTRIBUTE11        =>  p_lines_tab(l_index).Attribute11,
				     P_ATTRIBUTE12        =>  p_lines_tab(l_index).Attribute12,
				     P_ATTRIBUTE13        =>  p_lines_tab(l_index).Attribute13,
				     P_ATTRIBUTE14        =>  p_lines_tab(l_index).Attribute14,
				     P_ATTRIBUTE15        =>  p_lines_tab(l_index).Attribute15,
				     P_ATTRIBUTE_CATEGORY =>  p_lines_tab(l_index).Attribute_Category
			    ) THEN
	 RAISE FND_API.G_EXC_ERROR;
         END IF;

	 END LOOP;
	 if g_debug=1 then
	    debug('attribute columns for lines validated','Update_IC_Transaction_Flow');
	 end if;*/



	 --
         -- All data is validated can be updated to tables now
         --
         INV_TRANSACTION_FLOW_PVT.UPDATE_TRX_FLOW_HEADER(
                                                        P_HEADER_ID                     =>      p_header_id,
                                                        P_START_DATE                    =>      P_START_DATE,
                                                        P_END_DATE                      =>      P_END_DATE,
                                                        P_LAST_UPDATED_BY               =>      FND_GLOBAL.USER_ID,
                                                        P_LAST_UPDATE_DATE              =>      SYSDATE,
                                                        P_LAST_UPDATE_LOGIN             =>      FND_GLOBAL.LOGIN_ID,
                                                        P_ATTRIBUTE_CATEGORY            =>      P_ATTRIBUTE_CATEGORY,
                                                        P_ATTRIBUTE1                    =>      P_ATTRIBUTE1,
                                                        P_ATTRIBUTE2                    =>      P_ATTRIBUTE2,
                                                        P_ATTRIBUTE3                    =>      P_ATTRIBUTE3,
                                                        P_ATTRIBUTE4                    =>      P_ATTRIBUTE4,
                                                        P_ATTRIBUTE5                    =>      P_ATTRIBUTE5,
                                                        P_ATTRIBUTE6                    =>      P_ATTRIBUTE6,
                                                        P_ATTRIBUTE7                    =>      P_ATTRIBUTE7,
                                                        P_ATTRIBUTE8                    =>      P_ATTRIBUTE8,
                                                        P_ATTRIBUTE9                    =>      P_ATTRIBUTE9,
                                                        P_ATTRIBUTE10                   =>      P_ATTRIBUTE10,
                                                        P_ATTRIBUTE11                   =>      P_ATTRIBUTE11,
                                                        P_ATTRIBUTE12                   =>      P_ATTRIBUTE12,
                                                        P_ATTRIBUTE13                   =>      P_ATTRIBUTE13,
                                                        P_ATTRIBUTE14                   =>      P_ATTRIBUTE14,
                                                        P_ATTRIBUTE15                   =>      P_ATTRIBUTE15
                                                );
         if g_debug=1 then
	    debug('Header updated','Update_IC_Transaction_Flow');
	 end if;
	 -- update all the lines
         FOR l_index IN 1..p_lines_tab.count
         LOOP
                 INV_TRANSACTION_FLOW_PVT.UPDATE_TRX_FLOW_LINES(
                                                        P_Header_Id                     => p_header_id,
                                                        P_Line_Number                   => p_lines_tab(l_index).line_number,
                                                        P_Last_Updated_By               => FND_GLOBAL.USER_ID,
                                                        P_Last_Update_Date              => SYSDATE,
                                                        P_Last_Update_Login             => FND_GLOBAL.LOGIN_ID,
                                                        P_Attribute_Category            => p_lines_tab(l_index).Attribute_Category,
                                                        P_Attribute1                    => p_lines_tab(l_index).Attribute1,
                                                        P_Attribute2                    => p_lines_tab(l_index).Attribute2,
                                                        P_Attribute3                    => p_lines_tab(l_index).Attribute3,
                                                        P_Attribute4                    => p_lines_tab(l_index).Attribute4,
                                                        P_Attribute5                    => p_lines_tab(l_index).Attribute5,
                                                        P_Attribute6                    => p_lines_tab(l_index).Attribute6,
                                                        P_Attribute7                    => p_lines_tab(l_index).Attribute7,
                                                        P_Attribute8                    => p_lines_tab(l_index).Attribute8,
                                                        P_Attribute9                    => p_lines_tab(l_index).Attribute9,
                                                        P_Attribute10                   => p_lines_tab(l_index).Attribute10,
                                                        P_Attribute11                   => p_lines_tab(l_index).Attribute11,
                                                        P_Attribute12                   => p_lines_tab(l_index).Attribute12,
                                                        P_Attribute13                   => p_lines_tab(l_index).Attribute13,
                                                        P_Attribute14                   => p_lines_tab(l_index).Attribute14,
                                                        P_Attribute15                   => p_lines_tab(l_index).Attribute15
                                                        );
         END LOOP;
         if g_debug=1 then
	    debug('All lines updated','Update_IC_Transaction_Flow');
	 end if;

	 -- commit changes if asked
	 IF p_commit THEN
	    commit;
	 END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
                  x_return_status:=FND_API.G_RET_STS_ERROR;
                  ROLLBACK TO UPDATE_IC_TRX_FLOW_SP;
		  FND_MSG_PUB.COUNT_AND_GET(
                                        P_ENCODED=>'T',
                                        P_COUNT=>X_MSG_COUNT,
                                        P_DATA=>X_MSG_DATA);
         WHEN OTHERS THEN
                  x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
		  ROLLBACK TO UPDATE_IC_TRX_FLOW_SP;
                  FND_MSG_PUB.COUNT_AND_GET(
                                        P_ENCODED=>'T',
                                        P_COUNT=>X_MSG_COUNT,
                                        P_DATA=>X_MSG_DATA);
END;

/*=======================================================================================================*/

PROCEDURE update_ic_txn_flow_hdr
  (X_RETURN_STATUS	   OUT NOCOPY	VARCHAR2,
   X_MSG_COUNT		   OUT NOCOPY	NUMBER,
   X_MSG_DATA		   OUT NOCOPY	VARCHAR2,
   P_COMMIT		   IN		BOOLEAN DEFAULT FALSE,
   P_HEADER_ID		   IN		NUMBER,
   P_START_DATE	           IN		DATE,
   P_END_DATE		   IN		DATE,
   P_REF_DATE		   IN		DATE,
   P_ATTRIBUTE_CATEGORY    IN		VARCHAR2,
   P_ATTRIBUTE1	           IN		VARCHAR2,
   P_ATTRIBUTE2	           IN		VARCHAR2,
   P_ATTRIBUTE3	           IN		VARCHAR2,
   P_ATTRIBUTE4	           IN		VARCHAR2,
   P_ATTRIBUTE5	           IN		VARCHAR2,
   P_ATTRIBUTE6	           IN		VARCHAR2,
   P_ATTRIBUTE7	           IN		VARCHAR2,
   P_ATTRIBUTE8	           IN		VARCHAR2,
   P_ATTRIBUTE9	           IN		VARCHAR2,
   P_ATTRIBUTE10	   IN		VARCHAR2,
   P_ATTRIBUTE11	   IN		VARCHAR2,
   P_ATTRIBUTE12           IN		VARCHAR2,
   P_ATTRIBUTE13	   IN		VARCHAR2,
   P_ATTRIBUTE14	   IN		VARCHAR2,
   P_ATTRIBUTE15           IN		VARCHAR2
   ) IS

      l_start_org_id NUMBER;
      l_end_org_id NUMBER;
      l_flow_type NUMBER;
      l_organization_id NUMBER;
      l_qualifier_code NUMBER;
      l_qualifier_value_id NUMBER;
      l_start_date DATE;
      l_end_date   DATE;
      l_updated_start_date DATE;
      l_updated_end_date DATE;

BEGIN
   if g_debug=1 then
      debug('Starting Update_IC_Transaction_Flow','Update_IC_Txn_Flow_hdr');
   end if;

   if g_debug=1 then
      debug('p_start_date='||p_start_date,'Update_IC_Txn_Flow_hdr');
      debug('p_end_date='||p_end_date,'Update_IC_Txn_Flow_hdr');
      debug('p_ref_date='||p_ref_date,'Update_IC_Txn_Flow_hdr');
   end if;

   SAVEPOINT UPDATE_IC_TRX_FLOW_HDR_SP;

   x_return_status:=FND_API.G_RET_STS_SUCCESS;

   -- accuire lock for header
   BEGIN
      SELECT START_ORG_ID,END_ORG_ID,FLOW_TYPE,ORGANIZATION_ID,
	QUALIFIER_CODE,QUALIFIER_VALUE_ID,START_DATE,END_DATE
	INTO l_start_org_id,l_end_org_id,l_flow_type,l_organization_id,
	l_qualifier_code,l_qualifier_value_id,l_start_date,l_end_date
	FROM MTL_TRANSACTION_FLOW_HEADERS
	WHERE HEADER_ID=P_HEADER_ID
	FOR UPDATE OF START_DATE,END_DATE NOWAIT;
      if g_debug=1 then
	 debug('Lock accuired for header','Update_IC_Txn_Flow_hdr');
      end if;
   EXCEPTION
      WHEN OTHERS THEN
	 -- unable to accuire lock for update
	 -- ACTION
	 if g_debug=1 then
	    debug('Failed to accuire lock for header','Update_IC_Txn_Flow_hdr');
	 end if;
	 FND_MESSAGE.SET_NAME('INV','INV_LOCK_FAILED');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
   END;

   IF p_start_date <> l_start_date THEN
      -- do the validation
      IF NOT INV_TRANSACTION_FLOW_PVT.Validate_Start_Date(
							  P_HEADER_ID             => p_header_id,
							  P_START_ORG_ID          => l_start_org_id,
							  P_END_ORG_ID            => l_end_org_id,
							  P_FLOW_TYPE             => l_flow_type,
							  P_ORGANIZATION_ID       => l_organization_id,
							  P_QUALIFIER_CODE        => l_qualifier_code,
							  P_QUALIFIER_VALUE_ID    => l_qualifier_value_id,
							  P_START_DATE            => p_start_date,
							  P_REF_DATE              => p_ref_date
							  )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   IF nvl(p_end_date,sysdate) <> nvl(l_end_date,sysdate) THEN
      -- do the validations
      IF NOT INV_TRANSACTION_FLOW_PVT.Validate_End_Date(
	                                                P_HEADER_ID             => p_header_id,
                                                        P_START_ORG_ID          => l_start_org_id,
                                                        P_END_ORG_ID            => l_end_org_id,
                                                        P_FLOW_TYPE             => l_flow_type,
                                                        P_ORGANIZATION_ID       => l_organization_id,
                                                        P_QUALIFIER_CODE        => l_qualifier_code,
                                                        P_QUALIFIER_VALUE_ID    => l_qualifier_value_id,
                                                        P_START_DATE            => p_start_date,
                                                        P_END_DATE              => p_end_date,
							P_REF_DATE		=> p_ref_date
                                                        )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
          END IF;
   END IF;
   --
   --validate the attributes for the header before update

   IF NOT Validate_Dff  (        P_FLEX_NAME          => 'MTL_TXN_FLOW_HEADERS_DFF',
				 P_ATTRIBUTE1         =>  p_attribute1,
				 P_ATTRIBUTE2         =>  p_attribute2,
				 P_ATTRIBUTE3         =>  p_attribute3,
				 P_ATTRIBUTE4         =>  p_attribute4,
				 P_ATTRIBUTE5         =>  p_attribute5,
				 P_ATTRIBUTE6         =>  p_attribute6,
				 P_ATTRIBUTE7         =>  p_attribute7,
				 P_ATTRIBUTE8         =>  p_attribute8,
				 P_ATTRIBUTE9         =>  p_attribute9,
				 P_ATTRIBUTE10        =>  p_attribute10,
				 P_ATTRIBUTE11        =>  p_attribute11,
				 P_ATTRIBUTE12        =>  p_attribute12,
				 P_ATTRIBUTE13        =>  p_attribute13,
				 P_ATTRIBUTE14        =>  p_attribute14,
				 P_ATTRIBUTE15        =>  p_attribute15,
				 P_ATTRIBUTE_CATEGORY =>  p_attribute_category
				 ) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   if g_debug=1 then
      debug('attribute columns for header validated','Update_IC_Txn_Flow_hdr');
   end if;

   --
   -- All data is validated can be updated to tables now
   --
   INV_TRANSACTION_FLOW_PVT.update_trx_flow_header
     (P_HEADER_ID                     =>      p_header_id,
      P_START_DATE                    =>      P_START_DATE,
      P_END_DATE                      =>      P_END_DATE,
      P_LAST_UPDATED_BY               =>      FND_GLOBAL.USER_ID,
      P_LAST_UPDATE_DATE              =>      SYSDATE,
      P_LAST_UPDATE_LOGIN             =>      FND_GLOBAL.LOGIN_ID,
      P_ATTRIBUTE_CATEGORY            =>      P_ATTRIBUTE_CATEGORY,
      P_ATTRIBUTE1                    =>      P_ATTRIBUTE1,
      P_ATTRIBUTE2                    =>      P_ATTRIBUTE2,
      P_ATTRIBUTE3                    =>      P_ATTRIBUTE3,
      P_ATTRIBUTE4                    =>      P_ATTRIBUTE4,
      P_ATTRIBUTE5                    =>      P_ATTRIBUTE5,
      P_ATTRIBUTE6                    =>      P_ATTRIBUTE6,
     P_ATTRIBUTE7                    =>      P_ATTRIBUTE7,
     P_ATTRIBUTE8                    =>      P_ATTRIBUTE8,
     P_ATTRIBUTE9                    =>      P_ATTRIBUTE9,
     P_ATTRIBUTE10                   =>      P_ATTRIBUTE10,
     P_ATTRIBUTE11                   =>      P_ATTRIBUTE11,
     P_ATTRIBUTE12                   =>      P_ATTRIBUTE12,
     P_ATTRIBUTE13                   =>      P_ATTRIBUTE13,
     P_ATTRIBUTE14                   =>      P_ATTRIBUTE14,
     P_ATTRIBUTE15                   =>      P_ATTRIBUTE15
     );
   if g_debug=1 then
      debug('Header updated','Update_IC_Txn_Flow_hdr');
   end if;

   -- commit changes if asked
   IF p_commit THEN
      commit;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_ERROR;
      ROLLBACK TO UPDATE_IC_TRX_FLOW_HDR_SP;
      FND_MSG_PUB.COUNT_AND_GET(
				P_ENCODED=>'T',
				P_COUNT=>X_MSG_COUNT,
				P_DATA=>X_MSG_DATA);
   WHEN OTHERS THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO UPDATE_IC_TRX_FLOW_HDR_SP;
      FND_MSG_PUB.COUNT_AND_GET(
				P_ENCODED=>'T',
				P_COUNT=>X_MSG_COUNT,
				P_DATA=>X_MSG_DATA);
END;

/*=======================================================================================================*/

PROCEDURE Update_IC_Txn_Flow_line(
				    X_RETURN_STATUS	   OUT NOCOPY	VARCHAR2,
				    X_MSG_COUNT		   OUT NOCOPY	NUMBER,
				    X_MSG_DATA		   OUT NOCOPY	VARCHAR2,
				    P_COMMIT		   IN		BOOLEAN DEFAULT FALSE,
				    P_HEADER_ID		   IN		NUMBER,
				    P_LINE_NUMBER          IN           NUMBER,
				    P_ATTRIBUTE_CATEGORY   IN		VARCHAR2,
				    P_ATTRIBUTE1	   IN		VARCHAR2,
                                    P_ATTRIBUTE2	   IN		VARCHAR2,
				    P_ATTRIBUTE3	   IN		VARCHAR2,
                                    P_ATTRIBUTE4	   IN		VARCHAR2,
				    P_ATTRIBUTE5	   IN		VARCHAR2,
                                    P_ATTRIBUTE6	   IN		VARCHAR2,
				    P_ATTRIBUTE7	   IN		VARCHAR2,
                                    P_ATTRIBUTE8	   IN		VARCHAR2,
				    P_ATTRIBUTE9	   IN		VARCHAR2,
                                    P_ATTRIBUTE10	   IN		VARCHAR2,
				    P_ATTRIBUTE11	   IN		VARCHAR2,
                                    P_ATTRIBUTE12          IN		VARCHAR2,
				    P_ATTRIBUTE13	   IN		VARCHAR2,
				    P_ATTRIBUTE14	   IN		VARCHAR2,
                                    P_ATTRIBUTE15          IN		VARCHAR2
				    ) IS
				       l_from_org_id NUMBER;
BEGIN
   if g_debug=1 then
      debug('Starting Update_IC_Txn_Flow_line','Update_IC_Transaction_Flow');
   end if;


   SAVEPOINT UPDATE_IC_TRX_FLOW_LINE_SP;
   x_return_status:=FND_API.G_RET_STS_SUCCESS;

   -- accuire lock for lines
   BEGIN
      SELECT FROM_ORG_ID
	INTO l_from_org_id
	FROM MTL_TRANSACTION_FLOW_LINES
	WHERE HEADER_ID=p_header_id
	AND line_number=p_line_number
	FOR UPDATE NOWAIT;
      if g_debug=1 then
	 debug('Lock accuired for lines','Update_IC_Txn_Flow_line');
      end if;
   EXCEPTION
      WHEN OTHERS THEN
	 -- unable to accuire lock for update
	 -- ACTION
	 if g_debug=1 then
	    debug('Failed to accuire lock for lines','Update_IC_Txn_Flow_line');
	 end if;
	 FND_MESSAGE.SET_NAME('INV','INV_LOCK_FAILED');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
   END;

   --
   --Validate the flex columns for lines
   --
   IF NOT Validate_Dff(    P_FLEX_NAME          => 'MTL_TXN_FLOW_LINES_DFF',
			   P_ATTRIBUTE1         =>  p_Attribute1,
			   P_ATTRIBUTE2         =>  p_Attribute2,
			   P_ATTRIBUTE3         =>  p_Attribute3,
			   P_ATTRIBUTE4         =>  p_Attribute4,
			   P_ATTRIBUTE5         =>  p_Attribute5,
			   P_ATTRIBUTE6         =>  p_Attribute6,
			   P_ATTRIBUTE7         =>  p_Attribute7,
			   P_ATTRIBUTE8         =>  p_Attribute8,
			   P_ATTRIBUTE9         =>  p_Attribute9,
			   P_ATTRIBUTE10        =>  p_Attribute10,
			   P_ATTRIBUTE11        =>  p_Attribute11,
			   P_ATTRIBUTE12        =>  p_Attribute12,
			   P_ATTRIBUTE13        =>  p_Attribute13,
			   P_ATTRIBUTE14        =>  p_Attribute14,
			   P_ATTRIBUTE15        =>  p_Attribute15,
			   P_ATTRIBUTE_CATEGORY =>  p_Attribute_Category
			   ) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   if g_debug=1 then
      debug('attribute columns for lines validated','Update_IC_Txn_Flow_line');
   end if;

   INV_TRANSACTION_FLOW_PVT.UPDATE_TRX_FLOW_LINES(
						  P_Header_Id                     => p_header_id,
						  P_Line_Number                   => p_line_number,
						  P_Last_Updated_By               => FND_GLOBAL.USER_ID,
						  P_Last_Update_Date              => SYSDATE,
						  P_Last_Update_Login             => FND_GLOBAL.LOGIN_ID,
						  P_Attribute_Category            => p_Attribute_Category,
						  P_Attribute1                    => p_Attribute1,
						  P_Attribute2                    => p_Attribute2,
						  P_Attribute3                    => p_Attribute3,
						  P_Attribute4                    => p_Attribute4,
						  P_Attribute5                    => p_Attribute5,
						  P_Attribute6                    => p_Attribute6,
						  P_Attribute7                    => p_Attribute7,
						  P_Attribute8                    => p_Attribute8,
						  P_Attribute9                    => p_Attribute9,
						  P_Attribute10                   => p_Attribute10,
						  P_Attribute11                   => p_Attribute11,
                                                  P_Attribute12                   => p_Attribute12,
                                                  P_Attribute13                   => p_Attribute13,
                                                  P_Attribute14                   => p_Attribute14,
                                                  P_Attribute15                   => p_Attribute15
                                                  );
   if g_debug=1 then
      debug('All lines updated','Update_IC_Txn_Flow_line');
   end if;

   -- commit changes if asked
   IF p_commit THEN
      commit;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
                  x_return_status:=FND_API.G_RET_STS_ERROR;
                  ROLLBACK TO UPDATE_IC_TRX_FLOW_LINE_SP;
		  FND_MSG_PUB.COUNT_AND_GET(
					    P_ENCODED=>'T',
					    P_COUNT=>X_MSG_COUNT,
					    P_DATA=>X_MSG_DATA);
   WHEN OTHERS THEN
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO UPDATE_IC_TRX_FLOW_LINE_SP;
      FND_MSG_PUB.COUNT_AND_GET(
				P_ENCODED=>'T',
				P_COUNT=>X_MSG_COUNT,
				P_DATA=>X_MSG_DATA);
END;

/*=======================================================================================================*/

 -- This is a Table Handler for the header block
 --It will insert a row into the mtl_transaction_flow_headers

 PROCEDURE Insert_Trx_Flow_Header (
                                   P_Header_Id                   IN          NUMBER,
                                   P_Start_Org_Id                IN          NUMBER,
                                   P_End_Org_Id                  IN          NUMBER,
                                   P_Last_Update_Date            IN          DATE,
                                   P_Last_Updated_By             IN          NUMBER,
                                   P_Creation_Date               IN          DATE,
                                   P_Created_By                  IN          NUMBER,
                                   P_Last_Update_Login           IN          NUMBER,
                                   P_Flow_Type                   IN          NUMBER,
                                   P_Organization_Id             IN          NUMBER,
                                   P_Qualifier_Code              IN          NUMBER,
                                   P_Qualifier_Value_Id          IN          NUMBER,
                                   P_Asset_Item_Pricing_Option   IN          NUMBER,
                                   P_Expense_Item_Pricing_Option IN          NUMBER,
                                   P_Start_Date                  IN          DATE,
                                   P_End_Date                    IN          DATE,
                                   P_New_Accounting_Flag         IN          VARCHAR2,
                                   P_Attribute_Category          IN          VARCHAR2,
                                   P_Attribute1                  IN          VARCHAR2,
                                   P_Attribute2                  IN          VARCHAR2,
                                   P_Attribute3                  IN          VARCHAR2,
                                   P_Attribute4                  IN          VARCHAR2,
                                   P_Attribute5                  IN          VARCHAR2,
                                   P_Attribute6                  IN          VARCHAR2,
                                   P_Attribute7                  IN          VARCHAR2,
                                   P_Attribute8                  IN          VARCHAR2,
                                   P_Attribute9                  IN          VARCHAR2,
                                   P_Attribute10                 IN          VARCHAR2,
                                   P_Attribute11                 IN          VARCHAR2,
                                   P_Attribute12                 IN          VARCHAR2,
                                   P_Attribute13                 IN          VARCHAR2,
                                   P_Attribute14                 IN          VARCHAR2,
                                   P_Attribute15                 IN          VARCHAR2
               ) IS
 BEGIN

       insert into mtl_transaction_flow_headers
				(
					header_id,
					start_org_id,
					end_org_id,
					last_update_date,
					last_updated_by,
					creation_date,
					created_by,
					last_update_login,
					flow_type,
					organization_id,
					qualifier_code,
					qualifier_value_id,
					asset_item_pricing_option,
					expense_item_pricing_option,
					start_date,
					end_date,
					new_accounting_flag,
					attribute_category,
					attribute1,
					attribute2,
					attribute3,
					attribute4,
					attribute5,
					attribute6,
					attribute7,
					attribute8,
					attribute9,
					attribute10,
					attribute11,
					attribute12,
					attribute13,
					attribute14,
					attribute15
				)

			VALUES (
					P_Header_Id,
					P_Start_Org_Id,
					P_End_Org_Id,
					P_Last_Update_Date,
					P_Last_Updated_By,
					P_Creation_Date,
					P_Created_By,
					P_Last_Update_Login,
					P_Flow_Type,
					P_Organization_Id,
					P_Qualifier_Code,
					P_Qualifier_Value_Id,
				        P_Asset_Item_Pricing_Option,
					P_Expense_Item_Pricing_Option,
					P_Start_Date,
					P_End_Date,
					P_New_Accounting_Flag,
					P_Attribute_Category,
					P_Attribute1,
					P_Attribute2,
					P_Attribute3,
					P_Attribute4,
					P_Attribute5,
					P_Attribute6,
					P_Attribute7,
					P_Attribute8,
					P_Attribute9,
					P_Attribute10,
					P_Attribute11,
					P_Attribute12,
					P_Attribute13,
					P_Attribute14,
					P_Attribute15
				);

   END Insert_Trx_Flow_Header;

/*=======================================================================================================*/
PROCEDURE Update_Trx_Flow_Header(
                                 P_Header_Id                   IN          NUMBER,
				 P_Last_Update_Date            IN          DATE,
                                 P_Last_Updated_By             IN          NUMBER,
                                 P_Last_Update_Login           IN          NUMBER,
                                 P_Start_Date                  IN          DATE,
                                 P_End_Date                    IN          DATE,
                                 P_Attribute_Category          IN          VARCHAR2,
                                 P_Attribute1                  IN          VARCHAR2,
                                 P_Attribute2                  IN          VARCHAR2,
                                 P_Attribute3                  IN          VARCHAR2,
                                 P_Attribute4                  IN          VARCHAR2,
                                 P_Attribute5                  IN          VARCHAR2,
                                 P_Attribute6                  IN          VARCHAR2,
                                 P_Attribute7                  IN          VARCHAR2,
                                 P_Attribute8                  IN          VARCHAR2,
                                 P_Attribute9                  IN          VARCHAR2,
                                 P_Attribute10                 IN          VARCHAR2,
                                 P_Attribute11                 IN          VARCHAR2,
                                 P_Attribute12                 IN          VARCHAR2,
                                 P_Attribute13                 IN          VARCHAR2,
                                 P_Attribute14                 IN          VARCHAR2,
                                 P_Attribute15                 IN          VARCHAR2
			      ) IS

BEGIN
if (g_debug=1) then
      debug('Inside UPDATE trx flow header','Update_Trx_Flow_Header');
end if;
Update MTL_TRANSACTION_FLOW_HEADERS
 SET

	START_DATE         = P_Start_Date,
	END_DATE           = P_End_Date,
	LAST_UPDATED_BY	   = P_Last_Updated_By,
	LAST_UPDATE_LOGIN  = P_Last_Update_Login,
	LAST_UPDATE_DATE   = P_Last_Update_Date,
	ATTRIBUTE_CATEGORY = P_Attribute_Category ,
	ATTRIBUTE1         = P_Attribute1,
	ATTRIBUTE2         = P_Attribute2,
	ATTRIBUTE3         = P_Attribute3,
	ATTRIBUTE4         = P_Attribute4,
	ATTRIBUTE5         = P_Attribute5,
	ATTRIBUTE6         = P_Attribute6,
	ATTRIBUTE7         = P_Attribute7,
	ATTRIBUTE8         = P_Attribute8,
	ATTRIBUTE9         = P_Attribute9,
	ATTRIBUTE10        = P_Attribute10,
	ATTRIBUTE11        = P_Attribute11,
	ATTRIBUTE12        = P_Attribute12,
	ATTRIBUTE13        = P_Attribute13,
	ATTRIBUTE14        = P_Attribute14,
	ATTRIBUTE15        = P_Attribute15
WHERE HEADER_ID = P_HEADER_ID;

END Update_Trx_Flow_Header;
/*=======================================================================================================*/

 -- This is a Table Handler for the header block
   --It will lock a row for update for the mtl_transaction_flow_headers

PROCEDURE Lock_Trx_Flow_Header   (
                                   P_Header_Id                   IN          NUMBER,
                                   P_Start_Org_Id                IN          NUMBER,
                                   P_End_Org_Id                  IN          NUMBER,
                                   P_Last_Update_Date            IN          DATE,
                                   P_Last_Updated_By             IN          NUMBER,
                                   P_Creation_Date               IN          DATE,
                                   P_Created_By                  IN          NUMBER,
                                   P_Last_Update_Login           IN          NUMBER,
                                   P_Flow_Type                   IN          NUMBER,
                                   P_Organization_Id             IN          NUMBER,
                                   P_Qualifier_Code              IN          NUMBER,
                                   P_Qualifier_Value_Id          IN          NUMBER,
                                   P_Asset_Item_Pricing_Option   IN          NUMBER,
                                   P_Expense_Item_Pricing_Option IN          NUMBER,
                                   P_Start_Date                  IN          DATE,
                                   P_End_Date                    IN          DATE,
                                   P_New_Accounting_Flag         IN          VARCHAR2,
                                   P_Attribute_Category          IN          VARCHAR2,
                                   P_Attribute1                  IN          VARCHAR2,
                                   P_Attribute2                  IN          VARCHAR2,
                                   P_Attribute3                  IN          VARCHAR2,
                                   P_Attribute4                  IN          VARCHAR2,
                                   P_Attribute5                  IN          VARCHAR2,
                                   P_Attribute6                  IN          VARCHAR2,
                                   P_Attribute7                  IN          VARCHAR2,
                                   P_Attribute8                  IN          VARCHAR2,
                                   P_Attribute9                  IN          VARCHAR2,
                                   P_Attribute10                 IN          VARCHAR2,
                                   P_Attribute11                 IN          VARCHAR2,
                                   P_Attribute12                 IN          VARCHAR2,
                                   P_Attribute13                 IN          VARCHAR2,
                                   P_Attribute14                 IN          VARCHAR2,
                                   P_Attribute15                 IN          VARCHAR2
                  ) IS


                CURSOR C IS
                    SELECT *
                    FROM   MTL_TRANSACTION_FLOW_HEADERS
                    WHERE  header_id=p_header_id
                    FOR UPDATE of Header_Id NOWAIT;

                Recinfo C%ROWTYPE;

BEGIN
   if (g_debug=1) then
      debug('Inside locl trx flow header','Lock_Trx_Flow_Header');
   end if;
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      FND_MSG_PUB.ADD;
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    if (
               (Recinfo.header_id =  P_Header_Id)
           AND (Recinfo.start_org_id =  P_Start_Org_Id)
           AND (Recinfo.end_org_id =  P_End_Org_Id)
           AND (Recinfo.flow_type =  P_Flow_Type)
           AND (   (Recinfo.organization_id =  P_Organization_Id)
                OR (    (Recinfo.organization_id IS NULL)
                    AND (P_Organization_Id IS NULL)))
           AND (   (Recinfo.qualifier_code =  P_Qualifier_Code)
                OR (    (Recinfo.qualifier_code IS NULL)
                    AND (P_Qualifier_Code IS NULL)))
           AND (   (Recinfo.qualifier_value_id =  P_Qualifier_Value_Id)
                OR (    (Recinfo.qualifier_value_id IS NULL)
                    AND (P_Qualifier_Value_Id IS NULL)))
           AND (   (Recinfo.asset_item_pricing_option =  P_Asset_Item_Pricing_Option)
                OR (    (Recinfo.asset_item_pricing_option IS NULL)
                    AND (P_Asset_Item_Pricing_Option IS NULL)))
           AND (   (Recinfo.expense_item_pricing_option =  P_Expense_Item_Pricing_Option)
                OR (    (Recinfo.Expense_item_pricing_option IS NULL)
                    AND (P_Expense_Item_Pricing_Option IS NULL)))
           AND (Recinfo.start_date=  P_Start_Date)
           AND (   (Recinfo.end_date =  P_End_Date)
                OR (    (Recinfo.end_date IS NULL)
                    AND (P_End_Date IS NULL)))
           AND (   (Recinfo.new_accounting_flag =  P_New_Accounting_Flag)
                OR (    (Recinfo.new_accounting_flag IS NULL)
                    AND (P_New_Accounting_Flag IS NULL)))
           AND (   (Recinfo.attribute_category =  P_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (P_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  P_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (P_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  P_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (P_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  P_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (P_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  P_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (P_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  P_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (P_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  P_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (P_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  P_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (P_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  P_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (P_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  P_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (P_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  P_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (P_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  P_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (P_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  P_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (P_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  P_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (P_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  P_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (P_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  P_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (P_Attribute15 IS NULL)))


      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      FND_MSG_PUB.ADD;
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Trx_Flow_Header;

/*=======================================================================================================*/




-- This is a Table Handler for the header block
--It will insert a row into the mtl_transaction_flow_lines
--Since Update is not allowed at lines block there are no table handlers
--for update and lock for the lines block

PROCEDURE Insert_Trx_Flow_Lines   (
                                   P_Header_Id               IN            NUMBER,
                                   P_Line_Number             IN            NUMBER,
                                   P_From_Org_Id             IN            NUMBER,
                                   P_From_Organization_Id    IN            NUMBER,
                                   P_To_Org_Id               IN            NUMBER,
                                   P_To_Organization_Id      IN            NUMBER,
                                   P_Last_Updated_By         IN            NUMBER,
                                   P_Last_Update_Date        IN            DATE,
                                   P_Creation_Date           IN            DATE,
                                   P_Created_By              IN            NUMBER,
                                   P_Last_Update_Login       IN            NUMBER,
                                   P_Attribute_Category      IN            VARCHAR2,
                                   P_Attribute1              IN            VARCHAR2,
                                   P_Attribute2              IN            VARCHAR2,
                                   P_Attribute3              IN            VARCHAR2,
                                   P_Attribute4              IN            VARCHAR2,
                                   P_Attribute5              IN            VARCHAR2,
                                   P_Attribute6              IN            VARCHAR2,
                                   P_Attribute7              IN            VARCHAR2,
                                   P_Attribute8              IN            VARCHAR2,
                                   P_Attribute9              IN            VARCHAR2,
                                   P_Attribute10             IN            VARCHAR2,
                                   P_Attribute11             IN            VARCHAR2,
                                   P_Attribute12             IN            VARCHAR2,
                                   P_Attribute13             IN            VARCHAR2,
                                   P_Attribute14             IN            VARCHAR2,
                                   P_Attribute15             IN            VARCHAR2
               ) IS

BEGIN

       insert into mtl_transaction_flow_lines
				   (
					header_id,
					line_number,
					from_org_id,
					from_organization_id,
					to_org_id,
					to_organization_id,
					last_updated_by,
					last_update_date,
					creation_date,
					created_by,
					last_update_login,
					attribute_category,
					attribute1,
					attribute2,
					attribute3,
					attribute4,
					attribute5,
					attribute6,
					attribute7,
					attribute8,
					attribute9,
					attribute10,
					attribute11,
					attribute12,
					attribute13,
					attribute14,
					attribute15
				    )

			     VALUES (

					P_Header_Id,
					P_Line_Number,
					P_From_Org_Id,
					P_From_Organization_Id,
					P_To_Org_Id,
					P_To_Organization_Id,
					P_Last_Updated_By,
					P_Last_Update_Date,
					P_Creation_Date,
					P_Created_By,
					P_Last_Update_Login,
					P_Attribute_Category,
					P_Attribute1,
					P_Attribute2,
					P_Attribute3,
					P_Attribute4,
					P_Attribute5,
					P_Attribute6,
					P_Attribute7,
					P_Attribute8,
					P_Attribute9,
					P_Attribute10,
					P_Attribute11,
					P_Attribute12,
					P_Attribute13,
					P_Attribute14,
					P_Attribute15

				   );

  END Insert_Trx_Flow_Lines;


/*=======================================================================================================*/

PROCEDURE Update_Trx_Flow_Lines (
                                 P_Header_Id                   IN          NUMBER,
				 P_Line_Number                 IN          NUMBER,
                                 P_Last_Update_Date            IN          DATE,
                                 P_Last_Updated_By             IN          NUMBER,
                                 P_Last_Update_Login           IN          NUMBER,
                                 P_Attribute_Category          IN          VARCHAR2,
                                 P_Attribute1                  IN          VARCHAR2,
                                 P_Attribute2                  IN          VARCHAR2,
                                 P_Attribute3                  IN          VARCHAR2,
                                 P_Attribute4                  IN          VARCHAR2,
                                 P_Attribute5                  IN          VARCHAR2,
                                 P_Attribute6                  IN          VARCHAR2,
                                 P_Attribute7                  IN          VARCHAR2,
                                 P_Attribute8                  IN          VARCHAR2,
                                 P_Attribute9                  IN          VARCHAR2,
                                 P_Attribute10                 IN          VARCHAR2,
                                 P_Attribute11                 IN          VARCHAR2,
                                 P_Attribute12                 IN          VARCHAR2,
                                 P_Attribute13                 IN          VARCHAR2,
                                 P_Attribute14                 IN          VARCHAR2,
                                 P_Attribute15                 IN          VARCHAR2
                               ) IS

BEGIN
if (g_debug=1) then
      debug('Inside UPDATE trx flow lines','Update_Trx_Flow_Lines');
end if;
Update MTL_TRANSACTION_FLOW_LINES
 SET
	LAST_UPDATED_BY	   = P_Last_Updated_By,
	LAST_UPDATE_LOGIN  = P_Last_Update_Login,
	LAST_UPDATE_DATE   = P_Last_Update_Date,
	ATTRIBUTE_CATEGORY = P_Attribute_Category ,
	ATTRIBUTE1         = P_Attribute1,
	ATTRIBUTE2         = P_Attribute2,
	ATTRIBUTE3         = P_Attribute3,
	ATTRIBUTE4         = P_Attribute4,
	ATTRIBUTE5         = P_Attribute5,
	ATTRIBUTE6         = P_Attribute6,
	ATTRIBUTE7         = P_Attribute7,
	ATTRIBUTE8         = P_Attribute8,
	ATTRIBUTE9         = P_Attribute9,
	ATTRIBUTE10        = P_Attribute10,
	ATTRIBUTE11        = P_Attribute11,
	ATTRIBUTE12        = P_Attribute12,
	ATTRIBUTE13        = P_Attribute13,
	ATTRIBUTE14        = P_Attribute14,
	ATTRIBUTE15        = P_Attribute15
     WHERE HEADER_ID = P_HEADER_ID
      AND LINE_NUMBER= P_LINE_NUMBER;

END Update_Trx_Flow_Lines;
/*=======================================================================================================*/
  PROCEDURE Lock_Trx_Flow_Lines     (
                                      P_Header_Id               IN            NUMBER,
                                      P_Line_Number             IN            NUMBER,
                                      P_From_Org_Id             IN            NUMBER,
                                      P_From_Organization_Id    IN            NUMBER,
                                      P_To_Org_Id               IN            NUMBER,
                                      P_To_Organization_Id      IN            NUMBER,
                                      P_Last_Updated_By         IN            NUMBER,
                                      P_Last_Update_Date        IN            DATE,
                                      P_Creation_Date           IN            DATE,
                                      P_Created_By              IN            NUMBER,
                                      P_Last_Update_Login       IN            NUMBER,
                                      P_Attribute_Category      IN            VARCHAR2,
                                      P_Attribute1              IN            VARCHAR2,
                                      P_Attribute2              IN            VARCHAR2,
                                      P_Attribute3              IN            VARCHAR2,
                                      P_Attribute4              IN            VARCHAR2,
                                      P_Attribute5              IN            VARCHAR2,
                                      P_Attribute6              IN            VARCHAR2,
                                      P_Attribute7              IN            VARCHAR2,
                                      P_Attribute8              IN            VARCHAR2,
                                      P_Attribute9              IN            VARCHAR2,
                                      P_Attribute10             IN            VARCHAR2,
                                      P_Attribute11             IN            VARCHAR2,
                                      P_Attribute12             IN            VARCHAR2,
                                      P_Attribute13             IN            VARCHAR2,
                                      P_Attribute14             IN            VARCHAR2,
                                      P_Attribute15             IN            VARCHAR2
                    ) IS


                  CURSOR C IS
                      SELECT *
                      FROM   MTL_TRANSACTION_FLOW_LINES
                      WHERE  header_id = P_Header_Id
		      and Line_Number=P_Line_Number
                      FOR UPDATE of Header_Id NOWAIT;

                  Recinfo C%ROWTYPE;

  BEGIN

      OPEN C;
      FETCH C INTO Recinfo;
      if (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
        FND_MSG_PUB.ADD;
        APP_EXCEPTION.Raise_Exception;
      end if;
      CLOSE C;

      if (
                 (Recinfo.header_id =    P_Header_Id)
             AND (Recinfo.line_number =  P_Line_Number)
             AND (Recinfo.from_org_id =  P_from_Org_Id)
             AND (   (Recinfo.from_organization_id =  P_From_Organization_Id)
                  OR (    (Recinfo.from_organization_id  IS NULL)
                      AND (P_From_Organization_Id IS NULL)))
             AND (Recinfo.to_org_id =  P_To_Org_Id)
             AND (   (Recinfo.to_organization_id =  P_To_Organization_Id)
                  OR (    (Recinfo.to_organization_id IS NULL)
                      AND (P_To_Organization_Id IS NULL)))
             AND (   (Recinfo.attribute_category =  P_Attribute_Category)
                  OR (    (Recinfo.attribute_category IS NULL)
                      AND (P_Attribute_Category IS NULL)))
             AND (   (Recinfo.attribute1 =  P_Attribute1)
                  OR (    (Recinfo.attribute1 IS NULL)
                      AND (P_Attribute1 IS NULL)))
             AND (   (Recinfo.attribute2 =  P_Attribute2)
                  OR (    (Recinfo.attribute2 IS NULL)
                      AND (P_Attribute2 IS NULL)))
             AND (   (Recinfo.attribute3 =  P_Attribute3)
                  OR (    (Recinfo.attribute3 IS NULL)
                      AND (P_Attribute3 IS NULL)))
             AND (   (Recinfo.attribute4 =  P_Attribute4)
                  OR (    (Recinfo.attribute4 IS NULL)
                      AND (P_Attribute4 IS NULL)))
             AND (   (Recinfo.attribute5 =  P_Attribute5)
                  OR (    (Recinfo.attribute5 IS NULL)
                      AND (P_Attribute5 IS NULL)))
             AND (   (Recinfo.attribute6 =  P_Attribute6)
                  OR (    (Recinfo.attribute6 IS NULL)
                      AND (P_Attribute6 IS NULL)))
             AND (   (Recinfo.attribute7 =  P_Attribute7)
                  OR (    (Recinfo.attribute7 IS NULL)
                      AND (P_Attribute7 IS NULL)))
             AND (   (Recinfo.attribute8 =  P_Attribute8)
                  OR (    (Recinfo.attribute8 IS NULL)
                      AND (P_Attribute8 IS NULL)))
             AND (   (Recinfo.attribute9 =  P_Attribute9)
                  OR (    (Recinfo.attribute9 IS NULL)
                      AND (P_Attribute9 IS NULL)))
             AND (   (Recinfo.attribute10 =  P_Attribute10)
                  OR (    (Recinfo.attribute10 IS NULL)
                      AND (P_Attribute10 IS NULL)))
             AND (   (Recinfo.attribute11 =  P_Attribute11)
                  OR (    (Recinfo.attribute11 IS NULL)
                      AND (P_Attribute11 IS NULL)))
             AND (   (Recinfo.attribute12 =  P_Attribute12)
                  OR (    (Recinfo.attribute12 IS NULL)
                      AND (P_Attribute12 IS NULL)))
             AND (   (Recinfo.attribute13 =  P_Attribute13)
                  OR (    (Recinfo.attribute13 IS NULL)
                      AND (P_Attribute13 IS NULL)))
             AND (   (Recinfo.attribute14 =  P_Attribute14)
                  OR (    (Recinfo.attribute14 IS NULL)
                      AND (P_Attribute14 IS NULL)))
             AND (   (Recinfo.attribute15 =  P_Attribute15)
                  OR (    (Recinfo.attribute15 IS NULL)
                      AND (P_Attribute15 IS NULL)))


        ) then
        return;
      else
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        FND_MSG_PUB.ADD;
        APP_EXCEPTION.Raise_Exception;
      end if;
    END Lock_Trx_Flow_Lines;

/*=======================================================================================================*/


END;-- INV_TRANSACTION_FLOW_PVT


/
