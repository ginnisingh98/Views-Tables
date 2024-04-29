--------------------------------------------------------
--  DDL for Package Body QP_ATTR_MAPPING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_ATTR_MAPPING_PUB" AS
/* $Header: QPXPSRCB.pls 120.14.12010000.10 2009/09/23 06:24:35 kdurgasi ship $ */

g_schema        VARCHAR2(30);
g_conc_mode     VARCHAR2(1);
g_err_mesg      VARCHAR2(2000);
line_number     NUMBER := 0;
segment_ctr     NUMBER := 0;

--fix for bug 2491269
G_PRICING_EVENT VARCHAR2(30);


l_debug VARCHAR2(3);


/* Private procedure to modify v_attr_scr string by substituting all occurences
   of:
	orig_hdr with new_hdr
	orig_line with new_line
   new_source is the package where the bulk structure is defined      */

PROCEDURE HVOP_Bulkify_Structures (v_attr_src_string IN OUT NOCOPY VARCHAR2,
				   orig_hdr	     IN VARCHAR2,
				   new_hdr 	     IN VARCHAR2,
				   orig_line	     IN VARCHAR2,
				   new_line	     IN VARCHAR2,
				   new_source        IN VARCHAR2
				  )
AS

source_ptr      NUMBER;
offset		NUMBER;
nth_replace     NUMBER;
Invalid_Attribute EXCEPTION;
PRAGMA EXCEPTION_INIT (Invalid_Attribute, -6550);
BEGIN

		v_attr_src_string := REPLACE (REPLACE (v_attr_src_string, orig_hdr, new_hdr), orig_line, new_line);
                nth_replace := 1;
                source_ptr := INSTR (v_attr_src_string, new_source, 1, nth_replace);

                WHILE source_ptr > 0
                LOOP
                	offset := INSTR (v_attr_src_string, ',', source_ptr , 1);
                	EXIT WHEN offset = 0;

			-- Check if attribute exists in HVOP structure
			BEGIN
				EXECUTE IMMEDIATE ('Declare test_attr ' || SUBSTR (v_attr_src_string, source_ptr, offset - source_ptr ) || '%type; Begin Null; End;');
			EXCEPTION
			WHEN Invalid_Attribute
			THEN
				put_line ('Invalid HVOP Attribute: ' || SUBSTR (v_attr_src_string, source_ptr, offset - source_ptr ));
				v_attr_src_string := 'NULL';
				RETURN;
			WHEN OTHERS
			THEN
				NULL;
			END;

                	v_attr_src_string := SUBSTR (v_attr_src_string, 1, offset - 1)
					     || '(i)'
					     || SUBSTR (v_attr_src_string, offset);
                	nth_replace := nth_replace + 1;
                	source_ptr := INSTR (v_attr_src_string, new_source, 1, nth_replace);
                END LOOP;

                IF source_ptr <> 0 THEN
                	offset := INSTR (v_attr_src_string, ')', source_ptr , 1);
                	IF offset = 0 THEN
                		offset := LENGTH(v_attr_src_string)+1;
                	END IF;

			-- Check if attribute exists in HVOP structure
			BEGIN
				EXECUTE IMMEDIATE ('Declare test_attr ' || SUBSTR (v_attr_src_string, source_ptr, offset - source_ptr  ) || '%type; Begin Null; End;');
			EXCEPTION
			WHEN Invalid_Attribute
			THEN
				put_line ('Invalid HVOP Attribute: ' || SUBSTR (v_attr_src_string, source_ptr, offset - source_ptr ));
				v_attr_src_string := 'NULL';
				RETURN;
			WHEN OTHERS
			THEN
				NULL;
			END;

                	v_attr_src_string := SUBSTR (v_attr_src_string, 1, offset - 1)
					     || '(i)'
					     || SUBSTR (v_attr_src_string, offset);
	        END IF;

END HVOP_Bulkify_Structures;


PROCEDURE Put_Line
     (Text VARCHAR2)
IS
BEGIN

   IF g_conc_mode IS NULL THEN

     IF NVL(Fnd_Profile.value('CONC_REQUEST_ID'),0) <> 0 THEN
          g_conc_mode := 'Y';
     ELSE
          g_conc_mode := 'N';
     END IF;

   END IF;

   IF g_conc_mode = 'Y' THEN
     Fnd_File.PUT_LINE(Fnd_File.LOG, Text);
   END IF;

END Put_Line;

/* Bug#4509601 - Procedure added to print messages in concurrent program
   output file.
*/
PROCEDURE Print_Line
     (Text VARCHAR2)
IS
BEGIN
   IF g_conc_mode IS NULL THEN
     IF NVL(Fnd_Profile.value('CONC_REQUEST_ID'),0) <> 0 THEN
          g_conc_mode := 'Y';
     ELSE
          g_conc_mode := 'N';
     END IF;
   END IF;

   IF g_conc_mode = 'Y' THEN
     Fnd_File.PUT_LINE(Fnd_File.OUTPUT, Text);
   END IF;
END Print_Line;


PROCEDURE Init_Applsys_Schema
IS
l_app_info		BOOLEAN;
l_status			VARCHAR2(30);
l_industry		VARCHAR2(30);
BEGIN

	IF g_schema IS NULL THEN

      l_app_info := Fnd_Installation.GET_APP_INFO
	    ('FND',l_status, l_industry, g_schema);

	END IF;

END;

PROCEDURE New_Line
IS
BEGIN

    line_number := line_number + 1;
    ad_ddl.build_package(' ',line_number);
--	 oe_debug_pub.add(' ');

END New_Line;

PROCEDURE COMMENT
(   p_comment	    IN  VARCHAR2
,   p_level	    IN  NUMBER DEFAULT 1
)
IS
BEGIN

    Text('--  '||p_comment,p_level);

END COMMENT;

PROCEDURE Break_Text
(   p_src_type  IN  VARCHAR2
,   p_string    IN  VARCHAR2
)
IS

  l_value_string VARCHAR2(2000) := p_string;
  l_temp1 VARCHAR2(2000);
  l_temp2 VARCHAR2(2000);
  l_filler VARCHAR2(20) := '                ';

  lp_position NUMBER := 0;
  rp_position NUMBER := 0;
  c_position NUMBER := 0;
  s_position NUMBER := 0;
  p NUMBER := 0;

BEGIN

  IF p_src_type = 'API' THEN
     Text('v_attr_value := ' , 3);
  ELSIF p_src_type = 'API_MULTIREC' THEN
     Text('v_attr_mvalue := ' , 3);
  END IF;

  WHILE LENGTH(l_value_string) > 200 LOOP

      lp_position := 0;
      rp_position := 0;
      c_position := 0;
      s_position := 0;
      p := 0;

      lp_position := INSTR(l_value_string,'(');
      rp_position := INSTR(l_value_string,')');
      c_position := INSTR(l_value_string,',');
      s_position := INSTR(l_value_string,' ');

      IF (lp_position > 0) AND (p = 0) THEN
         p := lp_position;
      ELSIF (c_position > 0) AND (p = 0) THEN
         p:= c_position;
      ELSIF (s_position > 0) AND (p = 0) THEN
         p:= s_position;
      ELSIF (rp_position > 0) AND (p = 0) THEN
         p:= rp_position;
      END IF;

      IF (lp_position > 0) AND (lp_position <= 200)  THEN
         l_temp1 := SUBSTR(l_value_string,1,lp_position);
         l_temp2 := SUBSTR(l_value_string,lp_position+1);
         l_value_string := l_temp2;
         Text(l_filler || l_temp1 , 3);
      ELSIF (c_position > 0) AND (c_position <= 200) THEN
         l_temp1 := SUBSTR(l_value_string,1,c_position);
         l_temp2 := SUBSTR(l_value_string,c_position+1);
         l_value_string := l_temp2;
         Text(l_filler || l_temp1 , 3);
      ELSIF (s_position > 0) AND (s_position <= 200) THEN
         l_temp1 := SUBSTR(l_value_string,1,s_position);
         l_temp2 := SUBSTR(l_value_string,s_position+1);
         l_value_string := l_temp2;
         Text(l_filler || l_temp1 , 3);
      ELSIF (rp_position > 0) AND (rp_position <= 200) THEN
         l_temp1 := SUBSTR(l_value_string,1,rp_position);
         l_temp2 := SUBSTR(l_value_string,rp_position+1);
         l_value_string := l_temp2;
         Text(l_filler || l_temp1 , 3);
      ELSE
         l_temp1 := SUBSTR(l_value_string,1,p);
         l_temp2 := SUBSTR(l_value_string,p+1);
         l_value_string := l_temp2;
         Text(l_filler || l_temp1 , 3);
      END IF;
  END LOOP;

  IF LENGTH(l_value_string) > 0 THEN
     Text(l_filler || l_value_string || ';' , 3);
  END IF;
END Break_Text;


PROCEDURE Text
(   p_string	IN  VARCHAR2
,   p_level	IN  NUMBER DEFAULT 1
)
IS
BEGIN

    line_number := line_number + 1;
    --dbms_output.put_line(LPAD(p_string,p_level*2+LENGTH(p_string)));
    ad_ddl.build_package(LPAD(p_string,p_level*2+LENGTH(p_string)),line_number);
--	 oe_debug_pub.add(LPAD(p_string,p_level*2+LENGTH(p_string)));

END text;

PROCEDURE Pkg_End
(   p_pkg_name	IN  VARCHAR2
,   p_pkg_type	IN  VARCHAR2
)
IS

l_is_pkg_body			VARCHAR2(30);
n					NUMBER := 0;
l_pkg_name			VARCHAR2(30);
l_new_pkg_name	CONSTANT	VARCHAR2(30) := 'QP_BUILD_SOURCING_PVT';
v_segment_id                    NUMBER;
v_count                         BINARY_INTEGER := 1;
CURSOR errors IS
	SELECT line, text
	FROM user_errors
	WHERE name = UPPER(l_pkg_name)
	  AND TYPE = DECODE(p_pkg_type,'SPEC','PACKAGE',
					'BODY','PACKAGE BODY');
BEGIN

    l_debug := Qp_Preq_Grp.G_DEBUG_ENGINE;
    --	end statement.
    Text('END '||p_pkg_name||';',0);

    --	Show errors.
    IF p_pkg_type = 'BODY' THEN
	l_is_pkg_body := 'TRUE';
    ELSE
	l_is_pkg_body := 'FALSE';
    END IF;

    PUT_LINE(
		'Call AD_DDL to create '||p_pkg_type||' of package '||p_pkg_name);
    IF l_debug = Fnd_Api.G_TRUE THEN
    Oe_Debug_Pub.ADD('Call AD_DDL to create '||p_pkg_type||' of package '||p_pkg_name);


    END IF;
    ad_ddl.create_package(applsys_schema => g_schema
	,application_short_name	=> 'QP'
	,package_name			=> p_pkg_name
	,is_package_body		=> l_is_pkg_body
	,lb					=> 1
	,ub					=> line_number);

    -- if there were any errors when creating this package, print out
    -- the errors in the log file
    l_pkg_name := p_pkg_name;
    FOR error IN errors LOOP
	 IF n= 0 THEN
	   PUT_LINE('ERROR in creating PACKAGE '||p_pkg_type||' :'||p_pkg_name);
	   --dbms_output.put_line('ERROR in creating PACKAGE '||p_pkg_type||' :'||p_pkg_name);
            IF l_debug = Fnd_Api.G_TRUE THEN
            Oe_Debug_Pub.ADD('ERROR in creating PACKAGE '||p_pkg_type||' :'||p_pkg_name);
            END IF;
	END IF;
	   PUT_LINE( 'LINE :'||error.line||' '||SUBSTR(error.text,1,200));
	   --dbms_output.put_line( 'LINE :'||error.line||' '||substr(error.text,1,200));
           IF l_debug = Fnd_Api.G_TRUE THEN
           Oe_Debug_Pub.ADD('LINE :'||error.line||' '||SUBSTR(error.text,1,200));
           END IF;
	   n := 1;
    END LOOP;

    -- if there was an error in compiling the package, raise
    -- an error
    IF  n > 0 THEN
	  --dbms_output.put_line('Raising Error now.....');
	  RAISE Fnd_Api.G_EXC_ERROR;
    END IF;


	--changes by spgopal 15-JUN-2001 for BUILD_SOURCE_TMP
   	IF n = 0
	THEN
	--no errors in the QP_BUILD_SOURCING_PVT_TMP
	--now go ahead generate the package
	--as QP_BUILD_SOURCING_PVT

		PUT_LINE('PACKAGE '||p_pkg_type||' Name to :'
			||l_pkg_name||' compiled successfully ');

                IF l_debug = Fnd_Api.G_TRUE THEN
                Oe_Debug_Pub.ADD('PACKAGE '||p_pkg_type||' Name to :'
                                 || l_pkg_name||' compiled successfully ');

                END IF;
		PUT_LINE('Now create PACKAGE '||p_pkg_type||' : '
			||l_new_pkg_name);

                IF l_debug = Fnd_Api.G_TRUE THEN
                Oe_Debug_Pub.ADD('Now create PACKAGE '||p_pkg_type||' : ' ||l_new_pkg_name);

                END IF;
		IF INSTR(ad_ddl.glprogtext(1),p_pkg_name) > 0
		THEN
			ad_ddl.glprogtext(1) :=
					REPLACE(ad_ddl.glprogtext(1)
						,p_pkg_name
						,l_new_pkg_name);
	   		PUT_LINE('First change : '
				||ad_ddl.glprogtext(1));

                        IF l_debug = Fnd_Api.G_TRUE THEN
                        Oe_Debug_Pub.ADD('First change : ' ||ad_ddl.glprogtext(1));

                        END IF;
			ad_ddl.glprogtext(line_number) :=
					REPLACE(ad_ddl.glprogtext(line_number)
						,p_pkg_name
						,l_new_pkg_name);
	   		PUT_LINE('Second change : '
				||' '||ad_ddl.glprogtext(line_number));

                        IF l_debug = Fnd_Api.G_TRUE THEN
                        Oe_Debug_Pub.ADD('Second change : ' ||' '||ad_ddl.glprogtext(line_number));

                        END IF;
	   		PUT_LINE('Trying to create PACKAGE '||p_pkg_type
				||' :'||l_new_pkg_name);

                        IF l_debug = Fnd_Api.G_TRUE THEN
                        Oe_Debug_Pub.ADD('Trying to create PACKAGE '||p_pkg_type
                                         ||' :'||l_new_pkg_name);

                        END IF;
			ad_ddl.create_package(applsys_schema => g_schema
			   ,application_short_name => 'QP'
			   ,package_name           => l_new_pkg_name
			   ,is_package_body        => l_is_pkg_body
			   ,lb                     => 1
			   ,ub                     => line_number);

			l_pkg_name := l_new_pkg_name;

	    		-- if there were any errors
			-- when creating this package, print out
	    		-- the errors in the log file
	    		FOR error IN errors LOOP
		 		IF n = 0 THEN
		   			PUT_LINE('ERROR in creating PACKAGE '
						||p_pkg_type||' :'||l_pkg_name);

                                        IF l_debug = Fnd_Api.G_TRUE THEN
                                        Oe_Debug_Pub.ADD('ERROR in creating PACKAGE '
                                                         ||p_pkg_type||' :'||l_pkg_name);

                                        END IF;
				END IF;
		   		PUT_LINE('LINE :'||error.line||' '
						||SUBSTR(error.text,1,200));

                                IF l_debug = Fnd_Api.G_TRUE THEN
                                Oe_Debug_Pub.ADD('LINE :'||error.line||' '
                                                 ||SUBSTR(error.text,1,200));
                                END IF;
		   		n := 1;
	    		END LOOP;

	    		-- if there was an error in compiling the package, raise
	    		-- an error
	    		IF  n > 0 THEN
		  		RAISE Fnd_Api.G_EXC_ERROR;
	    		END IF;
   			PUT_LINE('Generated PACKAGE '||p_pkg_type
				||' :'||l_new_pkg_name
				||' Successfully');

                        IF l_debug = Fnd_Api.G_TRUE THEN
                        Oe_Debug_Pub.ADD('Generated PACKAGE '||p_pkg_type
                                         ||' :'||l_new_pkg_name ||' Successfully');
                        END IF;

                        v_count := 1;

                        UPDATE qp_pte_segments
                        SET    sourcing_status = 'N',
                               used_in_setup = 'N'
                        WHERE  sourcing_status = 'Y' OR used_in_setup = 'Y';
                        LOOP

                               EXIT WHEN v_count > G_Segment_Ctr.COUNT;
                               v_segment_id := G_Segment_Ctr(v_count);
                               UPDATE qp_pte_segments
                               SET    sourcing_status = 'Y',
                                      used_in_setup = 'Y'
                               WHERE  segment_id = v_segment_id;

                               v_count := v_count + 1;

                        END LOOP;
                        COMMIT;
                        g_Segment_Ctr.DELETE;
                        Segment_Ctr := 0;
		ELSE
				NULL;
		END IF;--instr
	END IF;--n=0

    EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
	RAISE Fnd_Api.G_EXC_ERROR;
    WHEN OTHERS THEN
	 RAISE_APPLICATION_ERROR(-20000,SQLERRM||' '||ad_ddl.error_buf);
--	PUT_LINE('Iam into exception' ||ad_ddl.error_buf);
--	  RAISE FND_API.G_EXC_ERROR;

END Pkg_End;

-- Generates the Package Header for the package SPEC and BODY

PROCEDURE Pkg_Header
(   p_pkg_name	IN  VARCHAR2
,   p_pkg_type	IN  VARCHAR2
)
IS
header_string		VARCHAR2(200);
BEGIN

    -- Initialize line number
    line_number := 0;

--	Define package.

    IF p_pkg_type = 'BODY' THEN
	Text ('CREATE or REPLACE PACKAGE BODY '||
		p_pkg_name|| ' AS',0);
    ELSE
	Text ('CREATE or REPLACE PACKAGE '||
		p_pkg_name|| ' AUTHID CURRENT_USER AS',0);
    END IF;

    --	$Header clause.
    header_string := 'Header: QPXVBSTB.pls 115.0 '||SYSDATE||' 23:23:31 appldev ship ';
	Text('/* $'||header_string||'$ */',0);
	New_Line;

    --	Copyright section.

    COMMENT ( '',0 );
    COMMENT (
	'Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA',0);
    COMMENT ( 'All rights reserved.',0);
    COMMENT ( '',0);
    COMMENT ( 'FILENAME',0);
    COMMENT ( '',0);
    COMMENT ( '    '||p_pkg_name,0);
    COMMENT ( '',0);
    COMMENT ( 'DESCRIPTION',0);
    COMMENT ( '',0);
    COMMENT ( '    '||INITCAP(p_pkg_type)||' of package '
		||p_pkg_name,0);
    COMMENT ( '',0);
    COMMENT ('NOTES',0);
    COMMENT ( '',0);
    COMMENT ('HISTORY',0);
    COMMENT ( '',0);
    COMMENT ( TO_CHAR(SYSDATE)||' Created',0);
    COMMENT ( '',0);
    New_Line;

    --	Global constant holding package name.

    IF p_pkg_type = 'BODY' THEN
	COMMENT ( 'Global constant holding the package name',0);
        -- Global constatnt holding the package name will not be added
        /*
	Text (RPAD('G_PKG_NAME',30)||'CONSTANT '||
		    'VARCHAR2(30) := '''||p_pkg_name||''';',0);
        */
	New_Line;
    END IF;

END Pkg_Header;


PROCEDURE Create_Sourcing_Calls
( 	p_request_type_code		IN	VARCHAR2
,	p_pricing_type			IN 	VARCHAR2
,	p_HVOP_Call			IN 	VARCHAR2
)

IS

    v_db1  VARCHAR2(30);
    v_db2  VARCHAR2(30);
    v_is_used  VARCHAR2(1);
    v_condition_id       VARCHAR2(30);
    v_context_name       VARCHAR2(240);	--4932085, 4960278
    l_context_name       VARCHAR2(240); --4932085, 4960278
    v_attribute_name     VARCHAR2(240);
    l_attribute_name     VARCHAR2(240);
    v_attribute_value    VARCHAR2(240);
    v_attribute_mvalue   Qp_Attr_Mapping_Pub.t_MultiRecord;
    v_attr_src_string    VARCHAR2(2000);
    v_src_type           VARCHAR2(30);
    l_src_type           VARCHAR2(30);
    v_src_api_pkg        VARCHAR2(1000);
    l_src_api_pkg        VARCHAR2(1000);
    v_src_api_fn         VARCHAR2(1000);
    l_src_api_fn         VARCHAR2(1000);
    v_src_profile_option VARCHAR2(30);
    l_src_profile_option VARCHAR2(30);
    v_src_system_variable VARCHAR2(30);
    l_src_system_variable VARCHAR2(30);
    v_src_sys_code	 VARCHAR2(30);
    v_context_type	 VARCHAR2(30);
    l_context_type	 VARCHAR2(30);
    v_src_constant_value VARCHAR2(30);
    l_src_constant_value VARCHAR2(30);
    l_sourcing_level     VARCHAR2(30);
    l_value_string       VARCHAR2(2000);
    v_value_string       VARCHAR2(2000);
    l_segment_id         NUMBER;
    v_segment_id         NUMBER;
    v_count		 BINARY_INTEGER := 1;
    j			 NUMBER;
    source_ptr		 VARCHAR2(2000);
    offset 		 VARCHAR2(2000);

    --Fix for bug 2491269
    l_is_product         VARCHAR2(1);
    l_code_release_level CONSTANT VARCHAR2(30) := Qp_Code_Control.Get_Code_Release_Level;
    l_context_type_processed     VARCHAR2(30);

    L_CHECK_ACTIVE_FLAG  VARCHAR2(1);

    CURSOR l_ctxts(p_request_type_code VARCHAR2, p_db1 VARCHAR2, p_db2 VARCHAR2) IS
    SELECT
      arules.attribute_code,
      arules.src_type,
      arules.src_api_pkg,
      arules.src_api_fn,
      arules.src_profile_option,
      arules.src_system_variable_expr,
      arules.src_constant_value,
      condelem.value_string,
      condelem.attribute_code
    FROM
      oe_def_attr_condns aconds,
      oe_def_condn_elems condelem,
      oe_def_attr_def_rules arules
    WHERE
        aconds.database_object_name IN (p_db1, p_db2)
    AND condelem.condition_id = aconds.condition_id
    AND condelem.attribute_code IN ('PRICING_CONTEXT', 'QUALIFIER_CONTEXT')
    AND arules.attr_def_condition_id = aconds.attr_def_condition_id
--added this condition to look at enabled_flag to avoid duplicate sourcing due to
--OM changes to lct. enabled_flag is a new column introduced--spgopal
    AND NVL(aconds.enabled_flag, 'Y') = 'Y'
    AND EXISTS  (SELECT 'x' FROM qp_price_req_sources prs,oe_def_condn_elems condelem1
			WHERE condelem1.attribute_code = 'SRC_SYSTEM_CODE'
    			AND condelem1.value_string = prs.source_system_code
    			AND prs.request_type_code = p_request_type_code
			AND condelem.condition_id = condelem1.condition_id);

    CURSOR l_ctxts_new(p_request_type_code VARCHAR2, p_sourcing_level VARCHAR2) IS
    SELECT qpseg.segment_mapping_column attribute_code,
           qpsour.user_sourcing_type src_type,
           qpsour.user_value_string value_string,
           qpsour.segment_id,
           qpcon.prc_context_code context_code,
           qpcon.prc_context_type context_type,
	   '2' is_product
    FROM
           qp_segments_b qpseg,
           qp_attribute_sourcing qpsour,
           qp_prc_contexts_b qpcon,
           qp_pte_request_types_b qpreq,
           qp_pte_segments qppseg
    WHERE
           qpsour.segment_id = qpseg.segment_id
           AND qpsour.attribute_sourcing_level = p_sourcing_level
           AND qpsour.enabled_flag = 'Y'
           AND qpsour.request_type_code = p_request_type_code
           AND qpseg.prc_context_id = qpcon.prc_context_id
           AND qpreq.request_type_code = qpsour.request_type_code
           AND qppseg.pte_code = qpreq.pte_code
           AND qppseg.segment_id = qpsour.segment_id
           AND qppseg.sourcing_enabled = 'Y'
           AND qppseg.user_sourcing_method = 'ATTRIBUTE MAPPING'
           AND qpcon.prc_context_type IN ('PRICING_ATTRIBUTE', 'QUALIFIER')
    UNION
    SELECT qpseg.segment_mapping_column attribute_code,
           qpsour.user_sourcing_type src_type,
           qpsour.user_value_string value_string,
           qpsour.segment_id,
           qpcon.prc_context_code context_code,
           qpcon.prc_context_type context_type,
           '1' is_product
    FROM
           qp_segments_b qpseg,
           qp_attribute_sourcing qpsour,
           qp_prc_contexts_b qpcon,
           qp_pte_request_types_b qpreq,
           qp_pte_segments qppseg
    WHERE
           qpsour.segment_id = qpseg.segment_id
           AND qpsour.attribute_sourcing_level = p_sourcing_level
           AND qpsour.enabled_flag = 'Y'
           AND qpsour.request_type_code = p_request_type_code
           AND qpseg.prc_context_id = qpcon.prc_context_id
           AND qpreq.request_type_code = qpsour.request_type_code
           AND qppseg.pte_code = qpreq.pte_code
           AND qppseg.segment_id = qpsour.segment_id
           AND qppseg.sourcing_enabled = 'Y'
           AND qppseg.user_sourcing_method = 'ATTRIBUTE MAPPING'
           AND qpcon.prc_context_type = 'PRODUCT'
    ORDER BY is_product,attribute_code;

BEGIN

    l_debug := Qp_Preq_Grp.G_DEBUG_ENGINE;
    L_CHECK_ACTIVE_FLAG := NVL(Fnd_Profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
--fix for 2491269
	Text('QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;',1);

    IF NVL(G_ATTRMGR_INSTALLED,'N') = 'N' THEN

       IF p_pricing_type = 'L' THEN
          v_db1 := 'QP_LINE_PRICING_ATTRIBS_V';
	     v_db2 := 'QP_LINE_QUALIF_ATTRIBS_V';
       ELSIF p_pricing_type = 'H' THEN
          v_db1 := 'QP_HDR_PRICING_ATTRIBS_V';
          v_db2 := 'QP_HDR_QUALIF_ATTRIBS_V';
       END IF;

       G_Sourced_Contexts_Tbl.DELETE;
       v_count := 1;

       OPEN l_ctxts(p_request_type_code,v_db1,v_db2);

       LOOP

	   FETCH l_ctxts INTO
                         l_attribute_name,
   	                 l_src_type,
        	         l_src_api_pkg,
	   	         l_src_api_fn,
	   	         l_src_profile_option,
	   	         l_src_system_variable,
	   	         l_src_constant_value ,
	   	         l_context_name,
	   	         l_context_type;
     	   EXIT WHEN l_ctxts%NOTFOUND;

	   --oe_debug_pub.add('Attribute = ' || l_attribute_name);

	   --dbms_output.put_line ('#1');
	   v_is_used := 'N';

           IF L_CHECK_ACTIVE_FLAG = 'N' THEN
              IF (l_context_name = 'MODLIST') AND (l_attribute_name = 'QUALIFIER_ATTRIBUTE4') THEN

                 v_is_used := 'Y';

              ELSE

                 BEGIN

                    SELECT 'Y'
                    INTO   v_is_used
                    FROM   qp_qualifiers
                    WHERE  qualifier_context = l_context_name
                    AND    qualifier_attribute = l_attribute_name
                    AND    ROWNUM < 2;

                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN

                    BEGIN
                        --Bug#5007983 START
                        SELECT  'Y'
    			INTO    v_is_used
                        FROM    QP_PRICE_FORMULA_LINES A
                        WHERE   A.PRICING_ATTRIBUTE_CONTEXT = l_context_name
                        AND     A.PRICING_ATTRIBUTE = l_attribute_name
                        AND     EXISTS
                                (SELECT /*+ no_unest */ 'x'
                                FROM    QP_LIST_LINES B
                                WHERE   A.PRICE_FORMULA_ID = B.PRICE_BY_FORMULA_ID)
                        AND     ROWNUM < 2;

                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN

                     BEGIN
 		         SELECT 'Y'
   			 INTO   v_is_used
    			 FROM   qp_price_formula_lines a
   			 WHERE  a.pricing_attribute_context = l_context_name
   			 AND    a.pricing_attribute = l_attribute_name
   			 AND    EXISTS
                                (SELECT /*+ no_unest */ 'x'
                                FROM    qp_currency_details b
                                WHERE   a.price_formula_id = b.price_formula_id
                                OR      a.price_formula_id = b.markup_formula_id
                                )
   			 AND    ROWNUM < 2;
                        --Bug#5007983 END
                     EXCEPTION
                       WHEN NO_DATA_FOUND THEN

                       BEGIN

                          SELECT /*+ index(qp_pricing_attributes qp_pricing_attributes_n4) */ 'Y'
                          INTO   v_is_used
                          FROM   qp_pricing_attributes
                          WHERE  pricing_attribute_context = l_context_name
                          AND    pricing_attribute = l_attribute_name
                          AND    ROWNUM < 2;

                       EXCEPTION
                          WHEN NO_DATA_FOUND THEN

                          BEGIN

                             SELECT /*+ index(qp_pricing_attributes qp_pricing_attributes_n1) */ 'Y'
                             INTO   v_is_used
                             FROM   qp_pricing_attributes
                             WHERE  product_attribute_context = l_context_name
                             AND    product_attribute = l_attribute_name
                             AND    ROWNUM < 2;

                          EXCEPTION
                             WHEN NO_DATA_FOUND THEN
                             COMMENT('Attribute not used',0);
                          END;
                         END;
                       END;
                    END;
                 END;
              END IF;
           ELSIF L_CHECK_ACTIVE_FLAG = 'Y' THEN
	      IF (l_context_name = 'MODLIST') AND (l_attribute_name = 'QUALIFIER_ATTRIBUTE4') THEN

	         v_is_used := 'Y';

	      ELSE

                 BEGIN

      	            SELECT 'Y'
		    INTO   v_is_used
		    FROM   qp_qualifiers
		    WHERE  qualifier_context = l_context_name
		    AND    qualifier_attribute = l_attribute_name
		    AND    active_flag = 'Y'
		    AND    ROWNUM < 2;

	         EXCEPTION
		    WHEN NO_DATA_FOUND THEN

		    BEGIN
		        --Changes made by rnayani Bug # 4960639 START
                        /**
     		 	SELECT 'Y'
			INTO v_is_used
 			FROM   qp_price_formula_lines a, qp_list_lines b, qp_list_headers_b c
 			WHERE  a.pricing_attribute_context = l_context_name
  			AND    a.pricing_attribute = l_attribute_name
    			AND    a.price_formula_id = b.price_by_formula_id
    			AND    b.list_header_id = c.list_header_id
    			AND    c.active_flag = 'Y'
    			AND    rownum < 2;
                        **/
     		 	SELECT 'Y'
			INTO v_is_used
                        FROM qp_price_formula_lines a
                        WHERE a.pricing_attribute_context =  l_context_name AND
                        a.pricing_attribute = l_attribute_name AND
                        EXISTS (SELECT 'x'
                        FROM qp_list_lines b, qp_list_headers_b c
                        WHERE a.price_formula_id = b.price_by_formula_id AND
                        b.list_header_id = c.list_header_id AND
                        c.active_flag = 'Y')
                        AND ROWNUM < 2;
		        --Changes made by rnayani Bug # 4960639 END

                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN

                     BEGIN

                        --Bug#5007983 START
    		         SELECT 'Y'
   		         INTO   v_is_used
    			 FROM   qp_price_formula_lines a, qp_currency_details b
   			 WHERE  a.pricing_attribute_context = l_context_name
   			 AND    a.pricing_attribute = l_attribute_name
   			 AND    EXISTS
                                (SELECT /*+ no_unest */ 'x'
                                FROM    qp_currency_details b
                                WHERE   a.price_formula_id = b.price_formula_id
                                OR      a.price_formula_id = b.markup_formula_id
                                )
   			 AND    ROWNUM < 2;
                        --Bug#5007983 END

	            EXCEPTION
		       WHEN NO_DATA_FOUND THEN

		       BEGIN


                          SELECT /*+ index(qp_pricing_attributes qp_pricing_attributes_n4) */ 'Y'
		          INTO   v_is_used
		          FROM   qp_pricing_attributes
		          WHERE  pricing_attribute_context = l_context_name
		          AND    pricing_attribute = l_attribute_name
		          AND    list_header_id IN
                                 (SELECT list_header_id FROM qp_list_headers_b
                                  WHERE active_flag = 'Y')
		          AND    ROWNUM < 2;

		       EXCEPTION
		          WHEN NO_DATA_FOUND THEN

		          BEGIN

		             SELECT /*+ index(qp_pricing_attributes qp_pricing_attributes_n1) */ 'Y'
			     INTO   v_is_used
			     FROM   qp_pricing_attributes
			     WHERE  product_attribute_context = l_context_name
			     AND    product_attribute = l_attribute_name
		             AND    list_header_id IN
                                    (SELECT list_header_id FROM qp_list_headers_b
                                     WHERE active_flag = 'Y')
			     AND    ROWNUM < 2;

		          EXCEPTION
		             WHEN NO_DATA_FOUND THEN
                             BEGIN

                                SELECT 'Y'
                                INTO   v_is_used
                                FROM   qp_limits a, qp_list_headers_b b
                                WHERE  ((a.multival_attr1_context = l_context_name
                                AND    a.multival_attribute1 = l_attribute_name)
                                OR     (a.multival_attr2_context = l_context_name
                                AND    a.multival_attribute2 = l_attribute_name))
                                AND    a.list_header_id = b.list_header_id
                                AND    b.active_flag = 'Y'
                                AND    ROWNUM < 2;

		             EXCEPTION
		                WHEN NO_DATA_FOUND THEN
                                BEGIN

                                   SELECT 'Y'
                                   INTO   v_is_used
                                   FROM   qp_limit_attributes a, qp_limits b, qp_list_headers_b c
                                   WHERE  a.limit_attribute_context = l_context_name
                                   AND    a.limit_attribute = l_attribute_name
                                   AND    a.limit_id = b.limit_id
                                   AND    b.list_header_id = c.list_header_id
                                   AND    c.active_flag = 'Y'
                                   AND    ROWNUM < 2;

		                EXCEPTION
			           WHEN NO_DATA_FOUND THEN
			           COMMENT('Attribute not used',0);
		                END;
		             END;
		          END;
		       END;
                    END;
                  END;
	         END;
	      END IF;
	   END IF;
	   --oe_debug_pub.add('Enable Flag = ' || v_is_used);

	   --dbms_output.put_line ('#2');
	   IF v_is_used = 'Y' THEN

	      G_Sourced_Contexts_Tbl(v_count).attribute_name := l_attribute_name;
	      G_Sourced_Contexts_Tbl(v_count).src_type := l_src_type;
       	      G_Sourced_Contexts_Tbl(v_count).src_api_pkg := l_src_api_pkg;
	      G_Sourced_Contexts_Tbl(v_count).src_api_fn := l_src_api_fn;
	      G_Sourced_Contexts_Tbl(v_count).src_profile_option := l_src_profile_option;
	      G_Sourced_Contexts_Tbl(v_count).src_system_variable := l_src_system_variable;
	      G_Sourced_Contexts_Tbl(v_count).src_constant_value := l_src_constant_value;
	      G_Sourced_Contexts_Tbl(v_count).context_name := l_context_name;
	      G_Sourced_Contexts_Tbl(v_count).context_type := l_context_type;

	      v_count := v_count + 1;

           END IF;

       END LOOP;


       CLOSE l_ctxts;

	   --dbms_output.put_line ('#3');

       Text('IF p_req_type_code = ''' || p_request_type_code || ''' THEN', 0);
       New_Line;
       Text('IF p_pricing_type_code = ''' || p_pricing_type || ''' THEN',1);
       New_Line;
       Text('NULL;',2);
       New_Line;
       --HVOP loop through all attributes
        IF p_HVOP_call = 'Y' THEN
          Text('--HVOP Call');
          IF p_pricing_type = 'L' THEN
          Text('FOR i in QP_BULK_PREQ_GRP.G_LINE_REC.line_id.first..QP_BULK_PREQ_GRP.G_LINE_REC.line_id.last');
          --dbms_output.put_line('FOR i in QP_BULK_PREQ_GRP.G_LINE_REC.line_id.first..QP_BULK_PREQ_GRP.G_LINE_REC.line_id.last');
          Text('Loop');
	  Text ('If QP_BULK_PREQ_GRP.G_LINE_REC.header_id(i) IS NOT NULL Then',2);
	  Text ('If QP_BULK_PREQ_GRP.G_LINE_REC.header_id(i) = prev_header_id Then', 3);
	  Text ('QP_PREQ_GRP.G_NEW_PRICING_CALL := ''N'';', 4);
	  Text ('Else', 3);
	  Text ('QP_PREQ_GRP.G_NEW_PRICING_CALL := ''Y'';',4);
	  Text ('prev_header_id := QP_BULK_PREQ_GRP.G_LINE_REC.header_id(i);', 4);
	  Text ('End If;', 3);
	  Text ('Else', 2);
	  Text ('If QP_PREQ_GRP.G_NEW_PRICING_CALL = ''Y'' Then',3);
	  Text ('QP_PREQ_GRP.G_NEW_PRICING_CALL := ''N'';', 4);
	  Text ('End If;', 3);
	  Text ('End If;' , 2);
          ELSE
          Text('FOR i in QP_BULK_PREQ_GRP.G_HEADER_REC.header_id.first..QP_BULK_
PREQ_GRP.G_HEADER_REC.header_id.last');
          --dbms_output.put_line('FOR i in QP_BULK_PREQ_GRP.G_HEADER_REC.header_id.first..QP_BULK_PREQ_GRP.G_header_REC.header_id.last');
          Text('Loop');
          END IF;
        END IF;
      --HVOP loop through all attributes
       v_count := 0;

       LOOP

	   v_count := v_count + 1;

	   EXIT WHEN v_count > G_Sourced_Contexts_Tbl.COUNT;

	   v_attribute_name := G_Sourced_Contexts_Tbl(v_count).attribute_name;
	   v_src_type := G_Sourced_Contexts_Tbl(v_count).src_type;
           v_src_api_pkg := G_Sourced_Contexts_Tbl(v_count).src_api_pkg;
	   v_src_api_fn := G_Sourced_Contexts_Tbl(v_count).src_api_fn;
	   v_src_profile_option := G_Sourced_Contexts_Tbl(v_count).src_profile_option;
	   v_src_system_variable := G_Sourced_Contexts_Tbl(v_count).src_system_variable;
	   v_src_constant_value := G_Sourced_Contexts_Tbl(v_count).src_constant_value;
	   v_context_name := G_Sourced_Contexts_Tbl(v_count).context_name;
	   v_context_type := G_Sourced_Contexts_Tbl(v_count).context_type;

	   COMMENT('Src_Type: ' || v_src_type,0);

           --dbms_output.put_line('v_context_type 1: ' || v_context_type);


           IF v_src_type = 'API' THEN

	   --dbms_output.put_line ('#5');
	      v_attr_src_string := v_src_api_pkg || '.' || v_src_api_fn;

	      IF p_HVOP_call = 'Y'  AND INSTR(v_attr_src_string, 'OE_ORDER_PUB.'
) > 0 THEN --HVOP, replace old structure references

		HVOP_Bulkify_Structures ( v_attr_src_string,
					  'OE_ORDER_PUB.G_HDR',
					  'QP_BULK_PREQ_GRP.G_HEADER_REC',
					  'OE_ORDER_PUB.G_LINE',
					  'QP_BULK_PREQ_GRP.G_LINE_REC',
					  'QP_BULK_PREQ_GRP'
					);

              END IF;--p_HVOP_call

	      Text('BEGIN',2);
	      --Text('v_attr_value := ' || v_attr_src_string || ';', 3);
              Break_Text(v_src_type,v_attr_src_string);
	      Text('EXCEPTION',2);
	      Text('WHEN OTHERS THEN',3);
	      Text('v_attr_value := NULL;',4);
	      Text('END;',2);
	      New_Line;
	      Text('BEGIN',2);
	      Text('IF v_attr_value = FND_API.G_MISS_NUM THEN',2);
	      Text('v_attr_value := NULL;',3);
	      Text('END IF;',2);
	      Text('EXCEPTION',2);
	      Text('WHEN VALUE_ERROR THEN',3);
	      Text('IF v_attr_value = FND_API.G_MISS_CHAR THEN',4);
	      Text('v_attr_value := NULL;',5);
	      Text('END IF;',4);
	      Text('WHEN OTHERS THEN',3);
	      Text('v_attr_value := NULL;',4);
	      Text('END;',2);
	      New_Line;
	      Text('IF (v_attr_value IS NOT NULL) THEN',2);
	      New_Line;

	   END IF;

	   IF v_src_type = 'PROFILE_OPTION' THEN

	      v_attr_src_string := v_src_profile_option;


	      Text('BEGIN',2);
	      Text('v_attr_value := fnd_profile.value( ''' ||  v_attr_src_string || ''');', 3);
	      Text('EXCEPTION',2);
	      Text('WHEN OTHERS THEN',3);
	      Text('v_attr_value := NULL;',4);
	      Text('END;',2);
	      New_Line;
	      Text('IF (v_attr_value IS NOT NULL) THEN',2);
	      New_Line;

	   END IF;

	   IF v_src_type = 'SYSTEM' THEN

	      v_attr_src_string := v_src_system_variable;
	      Text('BEGIN',2);
	      Text('SELECT ' || v_attr_src_string || ' INTO v_attr_value FROM DUAL;', 3);
	      Text('EXCEPTION',2);
	      Text('WHEN OTHERS THEN',3);
	      Text('v_attr_value := NULL;',4);
	      Text('END;',2);
	      New_Line;
	      Text('IF (v_attr_value IS NOT NULL) THEN',2);
	      New_Line;

	   END IF;

	   IF v_src_type = 'CONSTANT' THEN

	      v_attr_src_string := v_src_constant_value;
	      Text('v_attr_value := ''' || v_attr_src_string || ''';', 3);
	      New_Line;
	      Text('IF (v_attr_value IS NOT NULL) THEN',2);
	      New_Line;

	   END IF;

	   IF v_src_type <> 'API_MULTIREC' THEN

	      IF v_context_type = 'QUALIFIER_CONTEXT' THEN


	 	 IF p_HVOP_call = 'Y' THEN --hvop

		   	 IF p_pricing_type = 'L' THEN --hvop: pricing type decides line index
			 	Text ('QP_BULK_PREQ_GRP.G_line_index(q_count) :=QP_BULK_PREQ_GRP.G_line_rec.line_index(i);');
		   	 ELSE  --header
			 	Text ('QP_BULK_PREQ_GRP.G_line_index(q_count) := i;');
		   	 END IF; --hvop: pricing type decides line index
      			 Text ('QP_BULK_PREQ_GRP.G_attr_type(q_count) := ''' || 'QUALIFIER' || ''';', 3);
               		 Text('QP_BULK_PREQ_GRP.G_attr_context(q_count) := ''' || v_context_name || ''';',3);
                 	 Text('QP_BULK_PREQ_GRP.G_attr_attr(q_count) := ''' || v_attribute_name || ''';',3);
                 	 Text('QP_BULK_PREQ_GRP.G_attr_value(q_count) := v_attr_value;',3);
			 Text ('QP_BULK_PREQ_GRP.G_validated_flag(q_count) := ''N'';', 3);
			 ------------------------put validated_flag code here-------
			 IF v_context_name = 'MODLIST'
			 AND
			 v_attribute_name = 'QUALIFIER_ATTRIBUTE4'
			 THEN
				Text ('If NVL(QP_BULK_PREQ_GRP.G_line_rec.agreement_id(i), FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM Then ', 3);
			 	Text ('QP_BULK_PREQ_GRP.G_validated_flag(q_count) := ''Y'';', 4);
				Text ('End If;', 4);
			END IF;



		 ELSE
		       	 Text('x_qual_ctxts_result_tbl(q_count).context_name := ''' || v_context_name || ''';',3);
		 	 Text('x_qual_ctxts_result_tbl(q_count).attribute_name := ''' || v_attribute_name || ''';',3);
		 	 Text('x_qual_ctxts_result_tbl(q_count).attribute_value := v_attr_value;',3);
		 END IF; --hvop

		 Text('q_count := q_count + 1;',3);
		 New_Line;
		 Text('END IF;',2);


	      ELSIF v_context_type = 'PRICING_CONTEXT' THEN

	 	 IF p_HVOP_call = 'Y' THEN --hvop

			 IF p_pricing_type = 'L' THEN --hvop: pricing type decides line index
				Text ('QP_BULK_PREQ_GRP.G_line_index(q_count) := QP_BULK_PREQ_GRP.G_line_rec.line_index(i);',3);
			 ELSE --header
				 Text ('QP_BULK_PREQ_GRP.G_line_index(q_count) := i;',3);
			 END IF; --hvop: pricing type decides line index

      			 Text ('QP_BULK_PREQ_GRP.G_attr_type(q_count) := ''' || 'PRICING' || ''';', 3);
               		 Text('QP_BULK_PREQ_GRP.G_attr_context(q_count) :=''' || v_context_name || ''';',3);
                 	 Text('QP_BULK_PREQ_GRP.G_attr_attr(q_count) := ''' || v_attribute_name || ''';',3);
                 	 Text('QP_BULK_PREQ_GRP.G_attr_value(q_count) := v_attr_value;',3);
			 Text ('QP_BULK_PREQ_GRP.G_validated_flag(q_count) := ''N'';', 3);
                 	 Text('q_count := q_count + 1;',3);
		ELSE
		 	Text('x_price_ctxts_result_tbl(p_count).context_name := ''' || v_context_name || ''';',3);
		 	Text('x_price_ctxts_result_tbl(p_count).attribute_name := ''' || v_attribute_name || ''';',3);
		 	Text('x_price_ctxts_result_tbl(p_count).attribute_value := v_attr_value;',3);
		 	Text('p_count := p_count + 1;',3);
		END IF;
		New_Line;
		Text('END IF;',2);

   	      END IF;

	   END IF;

	   IF v_src_type = 'API_MULTIREC' THEN

	      v_attr_src_string := v_src_api_pkg || '.' || v_src_api_fn;

              IF p_HVOP_call = 'Y'  AND INSTR(v_attr_src_string, 'OE_ORDER_PUB.') > 0 THEN
		HVOP_Bulkify_Structures ( v_attr_src_string,
                                          'OE_ORDER_PUB.G_HDR',
                                          'QP_BULK_PREQ_GRP.G_HEADER_REC',
                                          'OE_ORDER_PUB.G_LINE',
                                          'QP_BULK_PREQ_GRP.G_LINE_REC',
                                          'QP_BULK_PREQ_GRP'
                                        );
              END IF;--p_HVOP_call

	      Text('BEGIN',2);
              IF v_attr_src_string = 'NULL' THEN
	         Text('v_attr_mvalue(1) := ' || v_attr_src_string || ';', 3);
              ELSE
                 Break_Text(v_src_type,v_attr_src_string);
              END IF;
	      Text('EXCEPTION',2);
	      Text('WHEN OTHERS THEN',3);
              Text('IF l_debug = FND_API.G_TRUE THEN',4);
	      Text('oe_debug_pub.add(''Multirec API error'');',5);
              Text('END IF;',4);
	      Text('END;',2);
	      New_Line;
	      Text('IF (v_attr_mvalue.count <> 0) AND (v_attr_mvalue(1) IS NOT NULL) THEN',2);
	      Text('v_index := 1;',3);
	      Text('LOOP',3);

	      IF v_context_type = 'QUALIFIER_CONTEXT' THEN

	 	 IF p_HVOP_call = 'Y' THEN --hvop

		   	 IF p_pricing_type = 'L' THEN --hvop: pricing type decides line index
			 	Text ('QP_BULK_PREQ_GRP.G_line_index(q_count) := QP_BULK_PREQ_GRP.G_line_rec.line_index(i);',4);
		   	 ELSE  --header
			 	Text ('QP_BULK_PREQ_GRP.G_line_index(q_count) := i;',4);
		   	 END IF; --hvop: pricing type decides line index

      			 Text ('QP_BULK_PREQ_GRP.G_attr_type(q_count) := ''' || 'QUALIFIER' || ''';', 4);
               		 Text('QP_BULK_PREQ_GRP.G_attr_context(q_count) := ''' || v_context_name || ''';',4);
                 	 Text('QP_BULK_PREQ_GRP.G_attr_attr(q_count) := ''' || v_attribute_name || ''';',4);
                 	 Text('QP_BULK_PREQ_GRP.G_attr_value(q_count) := v_attr_mvalue(v_index);',4);
			 Text ('QP_BULK_PREQ_GRP.G_validated_flag(q_count) := ''N'';', 4);
			 ------------------------put validated_flag code here-------
			 IF v_context_name = 'MODLIST'
			 AND
			 v_attribute_name = 'QUALIFIER_ATTRIBUTE4'
			 THEN
				Text ('If NVL(QP_BULK_PREQ_GRP.G_line_rec.agreement_id(i), FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM Then ', 3);
			 	Text ('QP_BULK_PREQ_GRP.G_validated_flag(q_count) := ''Y'';', 4);
				Text ('End If;', 4);
			END IF;

		 ELSE
		       	 Text('x_qual_ctxts_result_tbl(q_count).context_name := ''' || v_context_name || ''';',4);
		 	 Text('x_qual_ctxts_result_tbl(q_count).attribute_name := ''' || v_attribute_name || ''';',4);
		 	 Text('x_qual_ctxts_result_tbl(q_count).attribute_value := v_attr_mvalue(v_index);',4);
		 END IF; --hvop

		 Text('q_count := q_count + 1;',4);
		 New_Line;

	      ELSIF v_context_type = 'PRICING_CONTEXT' THEN

	 	 IF p_HVOP_call = 'Y' THEN --hvop

			 IF p_pricing_type = 'L' THEN --hvop: pricing type decides line index
				 Text ('QP_BULK_PREQ_GRP.G_line_index(q_count) := QP_BULK_PREQ_GRP.G_line_rec.line_index(i);',3);
			 ELSE --header
				 Text ('QP_BULK_PREQ_GRP.G_line_index(q_count) := i;',4);
			 END IF; --hvop: pricing type decides line index

      			 Text ('QP_BULK_PREQ_GRP.G_attr_type(q_count) := ''' || 'PRICING' || ''';', 4);
               		 Text('QP_BULK_PREQ_GRP.G_attr_context(q_count) :=''' || v_context_name || ''';',4);
                 	 Text('QP_BULK_PREQ_GRP.G_attr_attr(q_count) := ''' || v_attribute_name || ''';',4);
                 	 Text('QP_BULK_PREQ_GRP.G_attr_value(q_count) := v_attr_mvalue(v_index);',4);
			 Text ('QP_BULK_PREQ_GRP.G_validated_flag(q_count) := ''N'';', 4);
                 	 Text('q_count := q_count + 1;',4);
		ELSE
		 	Text('x_price_ctxts_result_tbl(p_count).context_name := ''' || v_context_name || ''';',4);
		 	Text('x_price_ctxts_result_tbl(p_count).attribute_name := ''' || v_attribute_name || ''';',4);
		 	Text('x_price_ctxts_result_tbl(p_count).attribute_value := v_attr_mvalue(v_index);',4);
		 	Text('p_count := p_count + 1;',4);
		END IF;
		New_Line;
	      END IF;

	      New_Line;
	      Text('EXIT WHEN v_index = v_attr_mvalue.LAST;',4);
	      Text('v_index := v_index + 1;',4);
	      Text('END LOOP;',3);
	      Text('END IF;',2);

           END IF;

       END LOOP;

       Text('END IF;',1);
       New_Line;
       Text('END IF;',0);
    ELSIF NVL(G_ATTRMGR_INSTALLED,'N') = 'Y' THEN

       IF p_pricing_type = 'L' THEN
          l_sourcing_level := 'LINE';
       ELSIF p_pricing_type = 'H' THEN
          l_sourcing_level := 'ORDER';
       END IF;

       G_New_Sourced_Contexts_Tbl.DELETE;
       v_count := 1;

       OPEN l_ctxts_new(p_request_type_code,l_sourcing_level);

       LOOP

	   FETCH l_ctxts_new INTO
	   l_attribute_name,
	   l_src_type,
	   l_value_string,
	   l_segment_id,
	   l_context_name,
	   l_context_type,
           l_is_product;
       	   EXIT WHEN l_ctxts_new%NOTFOUND;


	   v_is_used := 'N';
           IF L_CHECK_ACTIVE_FLAG = 'N' THEN
              IF (l_context_name = 'MODLIST') AND (l_attribute_name = 'QUALIFIER_ATTRIBUTE4') THEN

                 v_is_used := 'Y';

              ELSE

                 BEGIN

                    SELECT 'Y'
                    INTO   v_is_used
                    FROM   qp_qualifiers
                    WHERE  qualifier_context = l_context_name
                    AND    qualifier_attribute = l_attribute_name
                    AND    ROWNUM < 2;

                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN

                    BEGIN

                    --Bug#5007983 START
                    SELECT 'Y'
    		    INTO   v_is_used
  		    FROM   qp_price_formula_lines a
  		    WHERE  a.pricing_attribute_context = l_context_name
   		    AND    a.pricing_attribute = l_attribute_name
   		    AND    EXISTS
                           (SELECT /*+ no_unest */ 'x'
                            FROM   qp_list_lines b
                            WHERE  a.price_formula_id = b.price_by_formula_id
                           )
    		    AND    ROWNUM < 2;
                    --Bug#5007983 END

                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN

                      BEGIN

                         --Bug#5007983 START
 			 SELECT 'Y'
   			 INTO   v_is_used
    			 FROM   qp_price_formula_lines a
   			 WHERE  a.pricing_attribute_context = l_context_name
   			 AND    a.pricing_attribute = l_attribute_name
   		         AND    EXISTS
                                (SELECT /*+ no_unest */ 'x'
                                 FROM   qp_currency_details b
                                 WHERE  a.price_formula_id = b.price_formula_id
                                 OR     a.price_formula_id = b.markup_formula_id
                                )
   			 AND    ROWNUM < 2;
                         --Bug#5007983 END

                     EXCEPTION
                       WHEN NO_DATA_FOUND THEN
  --bug 7494395
                       BEGIN
                          SELECT 'Y'
                          INTO v_is_used
                          FROM qp_currency_details
                          WHERE curr_attribute_type = l_context_type
                          AND   curr_attribute_context = l_context_name
                          AND   curr_attribute = l_attribute_name
                          AND   rownum < 2;

                       EXCEPTION
                         WHEN no_data_found then
    --bug 7494395
                       BEGIN

                          SELECT /*+ index(qp_pricing_attributes qp_pricing_attributes_n4) */ 'Y'
                          INTO   v_is_used
                          FROM   qp_pricing_attributes
                          WHERE  pricing_attribute_context = l_context_name
                          AND    pricing_attribute = l_attribute_name
                          AND    ROWNUM < 2;

                       EXCEPTION
                          WHEN NO_DATA_FOUND THEN

                          BEGIN

                             SELECT /*+ index(qp_pricing_attributes qp_pricing_attributes_n1) */ 'Y'
                             INTO   v_is_used
                             FROM   qp_pricing_attributes
                             WHERE  product_attribute_context = l_context_name
                             AND    product_attribute = l_attribute_name
                             AND    ROWNUM < 2;

                          EXCEPTION
                             WHEN NO_DATA_FOUND THEN
                             BEGIN
                                SELECT 'Y'
                                  INTO v_is_used
                                  FROM qp_list_lines
                                 WHERE ((break_uom_context = l_context_name
                                         AND break_uom_attribute = l_attribute_name)
                                              OR
                                        (accum_context = l_context_name
                                         AND accum_attribute = l_attribute_name)
                                       )
                                   AND ROWNUM < 2;

                             EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                  COMMENT('Attribute not used',0);
                             END;
                          END;
                         END;
                       END;
                    END;
                  END; --bug 7494395
                 END;
              END IF;
	   --dbms_output.put_line ('L_CHECK_ACTIVE_FLAG : ' || L_CHECK_ACTIVE_FLAG);
           ELSIF L_CHECK_ACTIVE_FLAG = 'Y' THEN
	   --dbms_output.put_line ('L_CHECK_ACTIVE_FLAG : ' || L_CHECK_ACTIVE_FLAG);
	      IF (l_context_name = 'MODLIST') AND (l_attribute_name = 'QUALIFIER_ATTRIBUTE4') THEN

	         v_is_used := 'Y';

	      ELSE

                 BEGIN

	            SELECT 'Y'
	            INTO   v_is_used
	            FROM   qp_qualifiers
	            WHERE  qualifier_context = l_context_name
	            AND    qualifier_attribute = l_attribute_name
		    AND    active_flag = 'Y'
	            AND    ROWNUM < 2;

	         EXCEPTION
	            WHEN NO_DATA_FOUND THEN

                    BEGIN

		        --Changes made by rnayani Bug # 4960639 START
                        /**
      		 	SELECT 'Y'
			INTO v_is_used
 			FROM   qp_price_formula_lines a, qp_list_lines b, qp_list_headers_b c
 			WHERE  a.pricing_attribute_context = l_context_name
  			AND    a.pricing_attribute = l_attribute_name
    			AND    a.price_formula_id = b.price_by_formula_id
    			AND    b.list_header_id = c.list_header_id
    			AND    c.active_flag = 'Y'
    			AND    rownum < 2;
                        **/
     		 	SELECT 'Y'
			INTO v_is_used
                        FROM qp_price_formula_lines a
                        WHERE a.pricing_attribute_context =  l_context_name AND
                        a.pricing_attribute = l_attribute_name AND
                        EXISTS (SELECT /*+ no_unest */ 'x'
                        FROM qp_list_lines b, qp_list_headers_b c
                        WHERE a.price_formula_id = b.price_by_formula_id AND
                        b.list_header_id = c.list_header_id AND
                        c.active_flag = 'Y')
                        AND ROWNUM < 2;
		        --Changes made by rnayani Bug # 4960639 END

                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN

                    BEGIN

                         --Bug#5007983 START
                	 SELECT 'Y'
   			 INTO   v_is_used
    			 FROM   qp_price_formula_lines a
   			 WHERE  a.pricing_attribute_context = l_context_name
   			 AND    a.pricing_attribute = l_attribute_name
   		         AND    EXISTS
                                (SELECT /*+ no_unest */ 'x'
                                 FROM   qp_currency_details b
                                 WHERE  a.price_formula_id = b.price_formula_id
                                 OR     a.price_formula_id = b.markup_formula_id
                                )
   			 AND    ROWNUM < 2;
                         --Bug#5007983 START

	            EXCEPTION
		       WHEN NO_DATA_FOUND THEN
  --bug 7494395
                       BEGIN
                          SELECT 'Y'
                          INTO v_is_used
                          FROM qp_currency_details
                          WHERE curr_attribute_type = l_context_type
                          AND   curr_attribute_context = l_context_name
                          AND   curr_attribute = l_attribute_name
                          AND   rownum < 2;

                       EXCEPTION
                         WHEN no_data_found then
 --bug 7494395
		       BEGIN

                          SELECT /*+ index(qp_pricing_attributes qp_pricing_attributes_n4) */ 'Y'
		          INTO   v_is_used
		          FROM   qp_pricing_attributes
		          WHERE  pricing_attribute_context = l_context_name
		          AND    pricing_attribute = l_attribute_name
		          AND    list_header_id IN
                                 (SELECT list_header_id FROM qp_list_headers_b
                                  WHERE active_flag = 'Y')
		          AND    ROWNUM < 2;

		       EXCEPTION
		          WHEN NO_DATA_FOUND THEN

	                  BEGIN

		             SELECT /*+ index(qp_pricing_attributes qp_pricing_attributes_n1) */ 'Y'
			     INTO   v_is_used
			     FROM   qp_pricing_attributes
			     WHERE  product_attribute_context = l_context_name
			     AND    product_attribute = l_attribute_name
		             AND    list_header_id IN
                                    (SELECT list_header_id FROM qp_list_headers_b
                                     WHERE active_flag = 'Y')
			     AND    ROWNUM < 2;

		          EXCEPTION
		             WHEN NO_DATA_FOUND THEN
                             BEGIN

                                SELECT 'Y'
                                INTO   v_is_used
                                FROM   qp_limits a, qp_list_headers_b b
                                WHERE  ((a.multival_attr1_context = l_context_name
                                AND    a.multival_attribute1 = l_attribute_name)
                                OR     (a.multival_attr2_context = l_context_name
                                AND    a.multival_attribute2 = l_attribute_name))
                                AND    a.list_header_id = b.list_header_id
                                AND    b.active_flag = 'Y'
                                AND    ROWNUM < 2;

		             EXCEPTION
		                WHEN NO_DATA_FOUND THEN
                                BEGIN

                                   SELECT 'Y'
                                   INTO   v_is_used
                                   FROM   qp_limit_attributes a, qp_limits b, qp_list_headers_b c
                                   WHERE  a.limit_attribute_context = l_context_name
                                   AND    a.limit_attribute = l_attribute_name
                                   AND    a.limit_id = b.limit_id
                                   AND    b.list_header_id = c.list_header_id
                                   AND    c.active_flag = 'Y'
                                   AND    ROWNUM < 2;


		                EXCEPTION
		                   WHEN NO_DATA_FOUND THEN
                                   BEGIN
                                      SELECT 'Y'
                                        INTO v_is_used
                                        FROM qp_list_lines a, qp_list_headers_b b
                                       WHERE ((a.break_uom_context = l_context_name
                                               AND a.break_uom_attribute = l_attribute_name)
                                                    OR
                                              (a.accum_context = l_context_name
                                               AND a.accum_attribute = l_attribute_name)
                                             )
                                         AND a.list_header_id = b.list_header_id
                                         AND b.active_flag = 'Y'
                                         AND ROWNUM < 2;

                                   EXCEPTION
                                      WHEN NO_DATA_FOUND THEN
                                        COMMENT('Attribute not used',0);
                                   END;
		                END;
		             END;
		          END;
                         END;
		       END;
                    END;
	         END;
                END; --bug 7494395
	      END IF;
	   END IF;
	   --oe_debug_pub.add('Enable Flag = ' || v_is_used);
	   --dbms_output.put_line('Enable Flag = ' || v_is_used);
	   IF v_is_used = 'Y' THEN
              segment_ctr := segment_ctr + 1;
  	      G_New_Sourced_Contexts_Tbl(v_count).attribute_name := l_attribute_name;
	      G_New_Sourced_Contexts_Tbl(v_count).src_type := l_src_type;
	      G_New_Sourced_Contexts_Tbl(v_count).value_string := l_value_string;
	      G_New_Sourced_Contexts_Tbl(v_count).context_name := l_context_name;
	      G_New_Sourced_Contexts_Tbl(v_count).context_type := l_context_type;

	      G_Segment_Ctr(segment_ctr) := l_segment_id;

	      v_count := v_count + 1;
	   END IF;

       END LOOP;

       --oe_debug_pub.add('Sourced contexts =  ' || G_New_Sourced_Contexts_Tbl.COUNT);

       CLOSE l_ctxts_new;


       Text('IF p_req_type_code = ''' || p_request_type_code || ''' THEN', 0);
       New_Line;
       Text('IF p_pricing_type_code = ''' || p_pricing_type || ''' THEN',1);
       New_Line;
       Text('NULL;',2);
       New_Line;
       --HVOP
        IF p_HVOP_call = 'Y' THEN
          Text('--HVOP Call');
          IF p_pricing_type = 'L' THEN
          Text('FOR i in QP_BULK_PREQ_GRP.G_LINE_REC.line_id.first..QP_BULK_PREQ_GRP.G_LINE_REC.line_id.last');
          --dbms_output.put_line('FOR i in QP_BULK_PREQ_GRP.G_LINE_REC.line_id.first..QP_BULK_PREQ_GRP.G_LINE_REC.line_id.last');
	  Text('Loop');
	  Text ('--oe_debug_pub.add (''prev_header_id: ''|| prev_header_id);');
	  Text ('--oe_debug_pub.add (''this_header_id: ''|| nvl(QP_BULK_PREQ_GRP.G_LINE_REC.header_id(i),0));');
          Text ('If QP_BULK_PREQ_GRP.G_LINE_REC.header_id(i) IS NOT NULL Then',2
);
          Text ('If QP_BULK_PREQ_GRP.G_LINE_REC.header_id(i) = prev_header_id Then', 3);
          Text ('QP_PREQ_GRP.G_NEW_PRICING_CALL := ''N'';', 4);
          Text ('Else', 3);
          Text ('QP_PREQ_GRP.G_NEW_PRICING_CALL := ''Y'';',4);
          Text ('prev_header_id := QP_BULK_PREQ_GRP.G_LINE_REC.header_id(i);');
          Text ('End If;', 3);
          Text ('Else', 2);
          Text ('If QP_PREQ_GRP.G_NEW_PRICING_CALL = ''Y'' Then',3);
          Text ('QP_PREQ_GRP.G_NEW_PRICING_CALL := ''N'';', 4);
	  Text ('--oe_debug_pub.add (''prev_header_id: ''|| prev_header_id);');
          Text ('End If;', 3);
          Text ('End If;' , 2);
          ELSE
          Text('FOR i in QP_BULK_PREQ_GRP.G_HEADER_REC.header_id.first..QP_BULK_PREQ_GRP.G_HEADER_REC.header_id.last');
          --dbms_output.put_line('FOR i in QP_BULK_PREQ_GRP.G_HEADER_REC.header_id.first..QP_BULK_PREQ_GRP.G_header_REC.header_id.last');
          Text('Loop');
          END IF;
        END IF;
      --HVOP
       v_count := 0;

       LOOP

           v_count := v_count + 1;


           EXIT WHEN v_count > G_New_Sourced_Contexts_Tbl.COUNT;

           v_attribute_name := G_New_Sourced_Contexts_Tbl(v_count).attribute_name;
           v_src_type := G_New_Sourced_Contexts_Tbl(v_count).src_type;
           v_value_string := G_New_Sourced_Contexts_Tbl(v_count).value_string;
           v_context_name := G_New_Sourced_Contexts_Tbl(v_count).context_name;
           v_context_type := G_New_Sourced_Contexts_Tbl(v_count).context_type;

--Fix for 2491269
           IF v_context_type <> 'PRODUCT'
           AND l_context_type_processed = 'PRODUCT'
	   AND l_code_release_level > '110508'
           THEN
                Text('IF l_debug = FND_API.G_TRUE THEN',2);
                text('oe_debug_pub.add(''In check to call line_group'');',3);
                Text('END IF;',2);
                Text('IF QP_ATTR_MAPPING_PUB.G_CHECK_LINE_FLAG = ''Y'' THEN',2);
                Text('BEGIN',3);
                Text('IF l_debug = FND_API.G_TRUE THEN',3);
                text('oe_debug_pub.add(''Before call line_group'');',4);
                Text('END IF;',3);
                Text('QP_ATTR_MAPPING_PUB.Check_line_group_items(p_pricing_type_code);',3);
                Text('IF l_debug = FND_API.G_TRUE THEN',3);
                text('oe_debug_pub.add(''After call line_group'');',4);
                Text('END IF;',3);
                Text('EXCEPTION',3);
                Text('WHEN OTHERS THEN',3);
                Text('IF l_debug = FND_API.G_TRUE THEN',4);
                Text('oe_debug_pub.add(''Error in Check_line_group_items'');',5);
                Text('END IF;',4);
                Text('END;',3);
                Text('ELSE--QP_ATTR_MAPPING_PUB.G_CHECK_LINE_FLAG',2);
		Text('QP_ATTR_MAPPING_PUB.G_PASS_THIS_LINE := ''Y'';',3);
                Text('END IF;--QP_ATTR_MAPPING_PUB.G_CHECK_LINE_FLAG',2);
	        Text('IF QP_ATTR_MAPPING_PUB.G_PASS_THIS_LINE = '||'''N''',2);
 	        Text(' OR QP_ATTR_MAPPING_PUB.G_IGNORE_PRICE = '||'''Y'''||' THEN',2);  --8589909
		Text('IF l_debug = FND_API.G_TRUE THEN',3);
                Text('oe_debug_pub.add(''Deleting sourced prod attr'');',4);
                Text('END IF;',3);
                Text('x_price_ctxts_result_tbl.delete;',3);
                Text('RETURN;',3);
                Text('END IF;--QP_ATTR_MAPPING_PUB.G_PASS_THIS_LINE',2);
           END IF;
--End Fix for 2491269


	   --dbms_output.put_line ('Src_Type: ' || v_src_type);
	   COMMENT('Src_Type: ' || v_src_type,0);

                l_context_type_processed := NULL;

           --dbms_output.put_line('v_context_type 2: ' || v_context_type);


           IF v_src_type = 'API' THEN

	      v_attr_src_string := v_value_string;

                IF p_HVOP_call = 'Y'  AND INSTR(v_attr_src_string, 'OE_ORDER_PUB.') > 0 THEN
		HVOP_Bulkify_Structures ( v_attr_src_string,
                                          'OE_ORDER_PUB.G_HDR',
                                          'QP_BULK_PREQ_GRP.G_HEADER_REC',
                                          'OE_ORDER_PUB.G_LINE',
                                          'QP_BULK_PREQ_GRP.G_LINE_REC',
                                          'QP_BULK_PREQ_GRP'
                                        );
	      --dbms_output.put_line ('v_attr_src_string: ' || v_attr_src_string);
              END IF;--p_HVOP_call

	      Text('BEGIN',2);
	      --Text('v_attr_value := ' || v_attr_src_string || ';', 3);
              Break_Text(v_src_type,v_attr_src_string);
	      Text('EXCEPTION',2);
	      Text('WHEN OTHERS THEN',3);
	      Text('v_attr_value := NULL;',4);
	      Text('END;',2);
	      New_Line;
	      Text('BEGIN',2);
	      Text('IF v_attr_value = FND_API.G_MISS_NUM THEN',2);
	      Text('v_attr_value := NULL;',3);
	      Text('END IF;',2);
	      Text('EXCEPTION',2);
	      Text('WHEN VALUE_ERROR THEN',3);
	      Text('IF v_attr_value = FND_API.G_MISS_CHAR THEN',4);
	      Text('v_attr_value := NULL;',5);
	      Text('END IF;',4);
	      Text('WHEN OTHERS THEN',3);
	      Text('v_attr_value := NULL;',4);
	      Text('END;',2);
	      New_Line;
	      Text('IF (v_attr_value IS NOT NULL) THEN',2);
	      New_Line;

	   END IF;

	   IF v_src_type = 'PROFILE_OPTION' THEN

	      v_attr_src_string := v_value_string;
	      Text('BEGIN',2);
	      Text('v_attr_value := fnd_profile.value( ''' ||  v_attr_src_string || ''');', 3);
	      Text('EXCEPTION',2);
	      Text('WHEN OTHERS THEN',3);
	      Text('v_attr_value := NULL;',4);
	      Text('END;',2);
	      New_Line;
	      Text('IF (v_attr_value IS NOT NULL) THEN',2);
	      New_Line;
           END IF;

	   IF v_src_type = 'SYSTEM' THEN

	      v_attr_src_string := v_value_string;
	      Text('BEGIN',2);
	      Text('SELECT ' || v_attr_src_string || ' INTO v_attr_value FROM DUAL;', 3);
	      Text('EXCEPTION',2);
	      Text('WHEN OTHERS THEN',3);
	      Text('v_attr_value := NULL;',4);
	      Text('END;',2);
	      New_Line;
	      Text('IF (v_attr_value IS NOT NULL) THEN',2);
	      New_Line;

	   END IF;

	   IF v_src_type = 'CONSTANT' THEN

	      v_attr_src_string := v_value_string;
	      Text('v_attr_value := ''' || v_attr_src_string || ''';', 3);
	      New_Line;
	      Text('IF (v_attr_value IS NOT NULL) THEN',2);
	      New_Line;

	   END IF;

	   IF v_src_type <> 'API_MULTIREC' THEN

	      IF v_context_type = 'QUALIFIER' THEN

                 IF p_HVOP_call = 'Y' THEN --hvop

                         IF p_pricing_type = 'L' THEN --hvop: pricing type decides line index
                                Text ('QP_BULK_PREQ_GRP.G_line_index(q_count) := QP_BULK_PREQ_GRP.G_line_rec.line_index(i);',4);
                         ELSE  --header
                                Text ('QP_BULK_PREQ_GRP.G_line_index(q_count) := i;',3);
                         END IF; --hvop: pricing type decides line index

                         Text ('QP_BULK_PREQ_GRP.G_attr_type(q_count) :=  ''' || 'QUALIFIER' || ''';', 3);
                         Text('QP_BULK_PREQ_GRP.G_attr_context(q_count) :=''' || v_context_name || ''';',3);
                         Text('QP_BULK_PREQ_GRP.G_attr_attr(q_count) := ''' || v_attribute_name || ''';',3);
                         Text('QP_BULK_PREQ_GRP.G_attr_value(q_count) := v_attr_value;',3);
			 Text ('QP_BULK_PREQ_GRP.G_validated_flag(q_count) := ''N'';', 3);
			 ------------------------put validated_flag code here-------
			 IF v_context_name = 'MODLIST'
			 AND
			 v_attribute_name = 'QUALIFIER_ATTRIBUTE4'
			 THEN
				Text ('If NVL(QP_BULK_PREQ_GRP.G_line_rec.agreement_id(i), FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM Then ', 3);
			 	Text ('QP_BULK_PREQ_GRP.G_validated_flag(q_count) := ''Y'';', 4);
				Text ('End If;', 4);
			END IF;

                 ELSE
                         Text('x_qual_ctxts_result_tbl(q_count).context_name := ''' || v_context_name || ''';',3);
                         Text('x_qual_ctxts_result_tbl(q_count).attribute_name := ''' || v_attribute_name || ''';',3);
                         Text('x_qual_ctxts_result_tbl(q_count).attribute_value := v_attr_value;',3);
                 END IF; --hvop

                 Text('q_count := q_count + 1;',3);


	      ELSIF v_context_type IN ('PRICING_ATTRIBUTE','PRODUCT') THEN

                 IF p_HVOP_call = 'Y' THEN --hvop

                         IF p_pricing_type = 'L' THEN --hvop: pricing type decides line index
                                 Text ('QP_BULK_PREQ_GRP.G_line_index(q_count) := QP_BULK_PREQ_GRP.G_line_rec.line_index(i);',3);
                         ELSE --header
                                 Text ('QP_BULK_PREQ_GRP.G_line_index(q_count) := i;',3);
                         END IF; --hvop: pricing type decides line index

                         Text ('QP_BULK_PREQ_GRP.G_attr_type(q_count) := ''' || SUBSTR(v_context_type, 1, 7) ||''';', 3);
                         Text('QP_BULK_PREQ_GRP.G_attr_context(q_count) :=''' || v_context_name || ''';',3);
                         Text('QP_BULK_PREQ_GRP.G_attr_attr(q_count) := ''' || v_attribute_name || ''';',3);
                         Text('QP_BULK_PREQ_GRP.G_attr_value(q_count) := v_attr_value;',3);
			 Text ('QP_BULK_PREQ_GRP.G_validated_flag(q_count) := ''N'';', 3);
	       		 Text('q_count := q_count + 1;',3);
                ELSE
                        Text('x_price_ctxts_result_tbl(p_count).context_name := ''' || v_context_name || ''';',3);
                        Text('x_price_ctxts_result_tbl(p_count).attribute_name := ''' || v_attribute_name || ''';',3);
                        Text('x_price_ctxts_result_tbl(p_count).attribute_value := v_attr_value;',3);
                        Text('p_count := p_count + 1;',4);
                END IF;
                New_Line;
              END IF;
              --added for changed lines performance improvement bug 2491269
              IF v_context_type = 'PRODUCT'
              AND l_code_release_level > '110508'
              THEN
                Text('IF l_debug = FND_API.G_TRUE THEN',4);
                text('oe_debug_pub.add(''Gathering product details'');',5);
                Text('END IF;',4);
                l_context_type_processed := v_context_type;
                Text('BEGIN',4);
                Text('QP_ATTR_MAPPING_PUB.G_Product_attr_tbl(QP_ATTR_MAPPING_PUB.G_Product_attr_tbl.COUNT+1) := '
                ||'x_price_ctxts_result_tbl(p_count-1);',5);
                Text('Exception',4);
                Text('When Others Then',4);
                Text('IF l_debug = FND_API.G_TRUE THEN',5);
                Text('oe_debug_pub.add(''No product sourced '');',6);
                Text('END IF;',5);
                Text('END;',4);
              END IF;--v_context_type = 'PRODUCT'
                Text('IF l_debug = FND_API.G_TRUE THEN',4);
                text('oe_debug_pub.add(''After product assigned'');',5);
                Text('END IF;',4);

                 Text('END IF;--v_attr_(m)value',2);


	   END IF;--v_src_type

	   IF v_src_type = 'API_MULTIREC' THEN

	      v_attr_src_string := v_value_string;

              IF p_HVOP_call = 'Y'  AND INSTR(v_attr_src_string, 'OE_ORDER_PUB.') > 0 THEN
		HVOP_Bulkify_Structures ( v_attr_src_string,
                                          'OE_ORDER_PUB.G_HDR',
                                          'QP_BULK_PREQ_GRP.G_HEADER_REC',
                                          'OE_ORDER_PUB.G_LINE',
                                          'QP_BULK_PREQ_GRP.G_LINE_REC',
                                          'QP_BULK_PREQ_GRP'
                                        );
              END IF;--p_HVOP_call

	      Text('BEGIN',2);
              IF v_attr_src_string = 'NULL' THEN
	         Text('v_attr_mvalue(1) := ' || v_attr_src_string || ';', 3);
              ELSE
                 Break_Text(v_src_type,v_attr_src_string);
              END IF;
	      Text('EXCEPTION',2);
	      Text('WHEN OTHERS THEN',3);
              Text('IF l_debug = FND_API.G_TRUE THEN',4);
	      Text('oe_debug_pub.add(''Multirec API error'');',5);
              Text('END IF;',4);
	      Text('END;',2);
	      New_Line;
	      Text('IF (v_attr_mvalue.count <> 0) AND (v_attr_mvalue(1) IS NOT NULL) THEN',2);
	      Text('v_index := 1;',3);
	      Text('LOOP',3);

	      IF v_context_type = 'QUALIFIER' THEN

                 IF p_HVOP_call = 'Y' THEN --hvop

                         IF p_pricing_type = 'L' THEN --hvop: pricing type decides line index
                                Text ('QP_BULK_PREQ_GRP.G_line_index(q_count) := QP_BULK_PREQ_GRP.G_line_rec.line_index(i);',4);
                         ELSE  --header
                                Text ('QP_BULK_PREQ_GRP.G_line_index(q_count) := i;',4);
                         END IF; --hvop: pricing type decides line index

                         Text ('QP_BULK_PREQ_GRP.G_attr_type(q_count) :=  ''' || 'QUALIFIER' || ''';', 4);
                         Text('QP_BULK_PREQ_GRP.G_attr_context(q_count) :=''' || v_context_name || ''';',4);
                         Text('QP_BULK_PREQ_GRP.G_attr_attr(q_count) := ''' || v_attribute_name || ''';',4);
                         Text('QP_BULK_PREQ_GRP.G_attr_value(q_count) := v_attr_mvalue(v_index);',4);
			 Text ('QP_BULK_PREQ_GRP.G_validated_flag(q_count) := ''N'';', 4);
			 ------------------------put validated_flag code here-------
			 IF v_context_name = 'MODLIST'
			 AND
			 v_attribute_name = 'QUALIFIER_ATTRIBUTE4'
			 THEN
				Text ('If NVL(QP_BULK_PREQ_GRP.G_line_rec.agreement_id(i), FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM Then ', 3);
			 	Text ('QP_BULK_PREQ_GRP.G_validated_flag(q_count) := ''Y'';', 4);
				Text ('End If;', 4);
			END IF;

                 ELSE
                         Text('x_qual_ctxts_result_tbl(q_count).context_name := ''' || v_context_name || ''';',4);
                         Text('x_qual_ctxts_result_tbl(q_count).attribute_name := ''' || v_attribute_name || ''';',4);
                         Text('x_qual_ctxts_result_tbl(q_count).attribute_value := v_attr_mvalue(v_index);',4);
                 END IF; --hvop

                 Text('q_count := q_count + 1;',4);
                 New_Line;


	      ELSIF v_context_type IN ('PRICING_ATTRIBUTE', 'PRODUCT') THEN

                 IF p_HVOP_call = 'Y' THEN --hvop

                         IF p_pricing_type = 'L' THEN --hvop: pricing type decides line index
                                 Text ('QP_BULK_PREQ_GRP.G_line_index(q_count) := QP_BULK_PREQ_GRP.G_line_rec.line_index(i);',3);
                         ELSE --header
                                 Text ('QP_BULK_PREQ_GRP.G_line_index(q_count) := i;',4);
                         END IF; --hvop: pricing type decides line index

                         Text ('QP_BULK_PREQ_GRP.G_attr_type(q_count) := ''' || SUBSTR(v_context_type, 1, 7) || ''';', 4);
                         Text('QP_BULK_PREQ_GRP.G_attr_context(q_count) :=''' || v_context_name || ''';',4);
                         Text('QP_BULK_PREQ_GRP.G_attr_attr(q_count) := ''' || v_attribute_name || ''';',4);
                         Text('QP_BULK_PREQ_GRP.G_attr_value(q_count) := v_attr_mvalue(v_index);',4);
			 Text ('QP_BULK_PREQ_GRP.G_validated_flag(q_count) := ''N'';', 4);
	 	         Text('q_count := q_count + 1;',4);
                ELSE
                        Text('x_price_ctxts_result_tbl(p_count).context_name := ''' || v_context_name || ''';',4);
                        Text('x_price_ctxts_result_tbl(p_count).attribute_name := ''' || v_attribute_name || ''';',4);
                        Text('x_price_ctxts_result_tbl(p_count).attribute_value := v_attr_mvalue(v_index);',4);
                        Text('p_count := p_count + 1;',4);
                END IF;
                New_Line;
              END IF;

              --added for changed lines performance improvement bug 2491269
              IF v_context_type = 'PRODUCT'
              AND l_code_release_level > '110508'
              THEN
                Text('IF l_debug = FND_API.G_TRUE THEN',4);
                text('oe_debug_pub.add(''Gathering product details'');',5);
                Text('END IF;',4);
                l_context_type_processed := v_context_type;
                Text('BEGIN',4);
                Text('QP_ATTR_MAPPING_PUB.G_Product_attr_tbl(QP_ATTR_MAPPING_PUB.G_Product_attr_tbl.COUNT+1) := '
                ||'x_price_ctxts_result_tbl(p_count-1);',5);
                Text('Exception',4);
                Text('When Others Then',4);
                Text('IF l_debug = FND_API.G_TRUE THEN',5);
                Text('oe_debug_pub.add(''No product sourced '');',6);
                Text('END IF;',5);
                Text('END;',4);
              END IF;--v_context_type = 'PRODUCT'
                Text('IF l_debug = FND_API.G_TRUE THEN',4);
                text('oe_debug_pub.add(''After product assigned'');',5);
                Text('END IF;',4);



	      New_Line;
	      Text('EXIT WHEN v_index = v_attr_mvalue.LAST;',4);
	      Text('v_index := v_index + 1;',4);
	      Text('END LOOP;',3);
              Text('END IF;--v_attr_(m)value',2);

           END IF;--v_src_type

       END LOOP;

	IF p_HVOP_Call = 'Y'  THEN
	Text('END LOOP;--hvop',2);
	New_Line;
	END IF;
       Text('END IF;',1);
       New_Line;
       Text('END IF;',0);
	New_Line;
    END IF;
EXCEPTION
WHEN OTHERS THEN
 --dbms_output.put_line ('SQLERRM: '||SQLERRM);
Text('SQLERRM: '||SQLERRM);

END Create_Sourcing_Calls;


PROCEDURE Build_Sourcing_Package
(
 err_buff                OUT NOCOPY VARCHAR2,
 retcode                 OUT NOCOPY NUMBER
)
IS

TYPE t_cursor IS REF CURSOR;
l_request_type_codes            t_cursor;
l_request_type_codes_new        t_cursor;
l_request_type_code		VARCHAR2(30);
l_sql_statement		        VARCHAR2(120);
v_is_used		        VARCHAR2(1) :='N';


BEGIN

        --dbms_output.put_line('............1............');
        --l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
        IF l_debug = Fnd_Api.G_TRUE THEN
        Oe_Debug_Pub.ADD('##### Begin Build Sourcing #####');

        END IF;
        --FND_PROFILE.GET('QP_ATTRIBUTE_MANAGER_INSTALLED',G_ATTRMGR_INSTALLED);
        --dbms_output.put_line('............11............');
        G_ATTRMGR_INSTALLED := Qp_Util.Attrmgr_Installed;
        --dbms_output.put_line('............111............');
      --dbms_output.put_line('Profile value is : ' || G_ATTRMGR_INSTALLED);

	Init_Applsys_Schema;

--	Writing out the body

--changes by spgopal 15-JUN-2001  = 'Y' for BUILD_SOURCE_TMP
	Pkg_Header('QP_BUILD_SOURCING_PVT_TMP', 'BODY');
	New_Line;
	Text('PROCEDURE Get_Attribute_Values',0);
	Text('(    p_req_type_code                IN VARCHAR2',0);
	Text(',    p_pricing_type_code            IN VARCHAR2',0);
	Text(',    x_qual_ctxts_result_tbl        OUT NOCOPY QP_Attr_Mapping_PUB.CONTEXTS_RESULT_TBL_TYPE',0);
	Text(',    x_price_ctxts_result_tbl       OUT NOCOPY QP_Attr_Mapping_PUB.CONTEXTS_RESULT_TBL_TYPE',0);
	Text(')',0);
	Text('IS',0);
	New_line;
	Text('v_attr_value         VARCHAR2(240);',0); --4932085, 4960278
	Text('v_attr_mvalue        QP_Attr_Mapping_PUB.t_MultiRecord;',0);
	Text('q_count              NUMBER := 1;',0);
	Text('p_count              NUMBER := 1;',0);
	Text('v_index              NUMBER := 1;',0);
	Text('v_tot_time           NUMBER := 0;',0);
	Text('prev_header_id 	   NUMBER := FND_API.G_MISS_NUM;',0);
	New_Line;
	Text('l_debug              VARCHAR2(3);',0);
	Text('BEGIN',0);
	Text('qp_debug_util.tstart(''FETCH_ATTRIBUTES'',''Fetching the Attribute Values'');',0);
	New_Line;

        Text('l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;',1);

	-- added for g_new_pricing_call for caching - hwong
	text('if p_pricing_type_code = ''H'' and qp_preq_grp.g_new_pricing_call = qp_preq_grp.g_no then', 0);
	text('qp_preq_grp.g_new_pricing_call := qp_preq_grp.g_yes;', 1);
        Text('IF l_debug = FND_API.G_TRUE THEN',1);
	text('oe_debug_pub.add(''hw/src/H: change to g_yes'');',2);
        Text('END IF;',1);
	text('end if;', 0);
	new_line;

        IF NVL(G_ATTRMGR_INSTALLED,'N') = 'N' THEN

	   OPEN   l_request_type_codes FOR
	   SELECT DISTINCT request_type_code
	   FROM   qp_price_req_sources;

	   IF Qp_Code_Control.Get_Code_Release_Level > '110509' THEN
	   	Text ('If QP_Util_PUB.HVOP_Pricing_On= ''N'' Then --Follow Non-HVOP Path',1);
	   END IF;
	   LOOP
		   FETCH l_request_type_codes INTO
		   l_request_type_code;

		   EXIT WHEN l_request_type_codes%NOTFOUND;

		   Create_Sourcing_Calls(l_request_type_code,'L');
		   Create_Sourcing_Calls(l_request_type_code,'H');

	   END LOOP;

		--HVOP
		   IF Qp_Code_Control.Get_Code_Release_Level > '110509' THEN
		     New_Line;
		     Text ('Else --Follow HVOP Path', 1);
			IF QP_JAVA_ENGINE_UTIL_PUB.JAVA_ENGINE_INSTALLED = 'Y' THEN --5295113, 5365971
		     Create_Sourcing_Calls('ONT','L','Y');
		     Create_Sourcing_Calls('ONT','H','Y');
			END IF;
			Text ('NULL;'); --5295113, 5365971
		     New_Line;
		     Text ('End If; --HVOP Path', 1);
		   END IF;--QP_CODE_CONTROL.Get_Code_Release_Level
		--HVOP

	   -- added for g_new_pricing_call for caching - hwong
          new_line;
	   Text ('If QP_Util_PUB.HVOP_Pricing_On= ''N'' Then');
	   text('if p_pricing_type_code = ''L'' and qp_preq_grp.g_new_pricing_call = qp_preq_grp.g_yes then', 1);
	   text('qp_preq_grp.g_new_pricing_call := qp_preq_grp.g_no;', 2);
           Text('IF l_debug = FND_API.G_TRUE THEN',2);
	   text('oe_debug_pub.add(''hw/src/L: change to g_no'');',3);
           Text('END IF;',2);
	   text('end if;', 1);
	   Text('End If;');
	   Text('qp_debug_util.tstop(''FETCH_ATTRIBUTES'',v_tot_time);',0);
	   Text('qp_debug_util.setAttribute(''BLD_CNTXT_ACCUM_TIME'', to_char(v_tot_time));',0);
	   New_Line;
	   Text('END Get_Attribute_Values;',0);
	   New_Line;
        ELSIF NVL(G_ATTRMGR_INSTALLED,'N') = 'Y' THEN
        --dbms_output.put_line('............2............');
           OPEN   l_request_type_codes_new FOR
           SELECT DISTINCT request_type_code
           FROM   QP_PTE_REQUEST_TYPES_B
	     WHERE ENABLED_FLAG = 'Y'; -- 5365644, 5365968

	   IF Qp_Code_Control.Get_Code_Release_Level > '110509' THEN
		Text ('If QP_Util_PUB.HVOP_Pricing_On= ''N'' Then --Follow Non-HVOP Path',1);
           END IF;
           LOOP

                FETCH l_request_type_codes_new INTO
                l_request_type_code;

                EXIT WHEN l_request_type_codes_new%NOTFOUND;

                Create_Sourcing_Calls(l_request_type_code,'L');
                Create_Sourcing_Calls(l_request_type_code,'H');

           END LOOP;
        --dbms_output.put_line('............3............');

		--HVOP
		   IF Qp_Code_Control.Get_Code_Release_Level > '110509' THEN
		     New_Line;
		     Text ('Else --Follow HVOP Path', 1);
			IF QP_JAVA_ENGINE_UTIL_PUB.JAVA_ENGINE_INSTALLED = 'Y' THEN  --5295113, 5365971
		     Create_Sourcing_Calls('ONT','L','Y');
		     Create_Sourcing_Calls('ONT','H','Y');
			END IF;
			Text ('NULL;');   --5295113, 5365971
		     New_Line;
		     Text ('End If; --HVOP Path', 1);
		   END IF;--QP_CODE_CONTROL.Get_Code_Release_Level
		--HVOP

		   -- added for g_new_pricing_call for caching - hwong
           new_line;
		   Text ('If QP_Util_PUB.HVOP_Pricing_On = ''N'' Then',1);
		   text('if p_pricing_type_code = ''L'' and qp_preq_grp.g_new_pricing_call = qp_preq_grp.g_yes then', 2);
		   text('qp_preq_grp.g_new_pricing_call := qp_preq_grp.g_no;', 3);
                   Text('IF l_debug = FND_API.G_TRUE THEN',3);
		   text('oe_debug_pub.add(''hw/src/L: change to g_no'');',4);
                   Text('END IF;',3);
		   text('end if;', 2);
		   Text ('End If;', 1);

           New_Line;
	   Text('qp_debug_util.tstop(''FETCH_ATTRIBUTES'',v_tot_time);',0);
	   Text('qp_debug_util.setAttribute(''BLD_CNTXT_ACCUM_TIME'', to_char(v_tot_time));',0);
	   Text('END Get_Attribute_Values;',0);
           New_Line;
        END IF;

	Text('FUNCTION Is_Attribute_Used (p_attribute_context IN VARCHAR2, p_attribute_code IN VARCHAR2)',0);
	Text('RETURN VARCHAR2',0);
	New_Line;
	Text('IS',0);
	New_line;
	Text('x_out	VARCHAR2(1) := ''N'';',0);
	Text('BEGIN',0);
	New_line;

	v_is_used := Is_Attribute_Used('VOLUME','PRICING_ATTRIBUTE10');

	Text('IF (p_attribute_context = ''VOLUME'') and (p_attribute_code = ''PRICING_ATTRIBUTE10'')',0);
	Text('THEN',0);
	Text('x_out := ''' || v_is_used || ''';',0);
	Text('END IF;',0);
	Text('IF (p_attribute_context = ''VOLUME'') and (p_attribute_code = ''PRICING_ATTRIBUTE12'')',0);

	v_is_used := Is_Attribute_Used('VOLUME','PRICING_ATTRIBUTE12');

	Text('THEN',0);
	Text('x_out := ''' || v_is_used || ''';',0);
	Text('END IF;',0);
	New_line;
	Text('RETURN x_out;',0);
	New_line;
	Text('END Is_Attribute_Used;',0);
	New_line;

--	Text('END QP_BUILD_SOURCING_PVT;',0);
--	Text('/',0);
--changes by spgopal 15-JUN-2001 for BUILD_SOURCE_TMP
        --dbms_output.put_line('............4............');
	Pkg_End('QP_BUILD_SOURCING_PVT_TMP', 'BODY');

        --dbms_output.put_line('............5............');
	retcode := 0;
        Fnd_Message.SET_NAME('QP','QP_ATTRIBUTE_SOURCING_SUCCESS');
        err_buff := Fnd_Message.GET;

        IF l_debug = Fnd_Api.G_TRUE THEN
        Oe_Debug_Pub.ADD('##### End Build Sourcing #####');

        END IF;
	EXCEPTION

  	WHEN Fnd_Api.G_EXC_ERROR THEN
                Fnd_Message.SET_NAME('QP','QP_ATTRIBUTE_SOURCING_ERROR');
                Fnd_Message.SET_TOKEN('PACKAGE_TYPE','BODY');
                Fnd_Message.SET_TOKEN('PACKAGE_NAME','QP_BUILD_SOURCING_PVT');
                Fnd_Message.SET_TOKEN('ERRMSG',SUBSTR(SQLERRM,1,150));
                err_buff := Fnd_Message.GET;
        	retcode := 2;

--        	err_buff := 'Please check the log file for error messages';

  	WHEN OTHERS THEN
                Fnd_Message.SET_NAME('QP','QP_ATTRIBUTE_SOURCING_ERROR');
                Fnd_Message.SET_TOKEN('PACKAGE_TYPE','BODY');
                Fnd_Message.SET_TOKEN('PACKAGE_NAME','QP_BUILD_SOURCING_PVT');
                Fnd_Message.SET_TOKEN('ERRMSG',SUBSTR(SQLERRM,1,150));
                err_buff := Fnd_Message.GET;
        	PUT_LINE( 'Error in creating QP_BUILD_SOURCING_PVT '||SQLERRM);
        	retcode := 2;
--        	err_buff := sqlerrm;


END Build_Sourcing_Package;


PROCEDURE Build_Contexts
(       p_request_type_code               IN      VARCHAR2
,       p_pricing_type                    IN      VARCHAR2
--added for MOAC
,       p_org_id                          IN NUMBER DEFAULT NULL
,       x_price_contexts_result_tbl       OUT     NOCOPY CONTEXTS_RESULT_TBL_TYPE
,       x_qual_contexts_result_tbl        OUT     NOCOPY CONTEXTS_RESULT_TBL_TYPE
)
IS

v_count                     NUMBER := 0;
l_count                     NUMBER := 0;

l_custom_sourced            VARCHAR2(1) := Fnd_Profile.VALUE('QP_CUSTOM_SOURCED');

l_req_type_code             VARCHAR2(30);
l_pricing_type_code         VARCHAR2(1);
l_qual_contexts_result_tbl     Qp_Attr_Mapping_Pub.CONTEXTS_RESULT_TBL_TYPE;
l_price_contexts_result_tbl    Qp_Attr_Mapping_Pub.CONTEXTS_RESULT_TBL_TYPE;

l_sourcing_start_time NUMBER;
l_sourcing_end_time   NUMBER;
l_time_difference     NUMBER;

BEGIN

-- Set the global variable G_DEBUG_ENGINE
  Qp_Preq_Grp.Set_QP_Debug;

--added for MOAC
--Set the Global variable G_ORG_ID
G_ORG_ID := NVL(p_org_id, Qp_Util.get_org_id);

    --added for moac
    --Initialize MOAC and set org context to Org passed in nvl(p_control_rec.org_id, mo_default_org_id)

    IF Mo_Global.get_access_mode IS NULL THEN
      Mo_Global.Init('QP');
      IF G_ORG_ID IS NOT NULL THEN
        Mo_Global.set_policy_context('S', G_ORG_ID);
      END IF;
    END IF;--MO_GLOBAL


  l_debug := Qp_Preq_Grp.G_DEBUG_ENGINE;

  IF l_debug = Fnd_Api.G_TRUE THEN
  Oe_Debug_Pub.ADD('##### Begin Build Contexts #####');
  END IF;
  --setting time
  l_sourcing_start_time := dbms_utility.get_time;

  Qp_Attr_Mapping_Pub.G_REQ_TYPE_CODE := p_request_type_code; --bug3848849

  Qp_Build_Sourcing_Pvt.Get_Attribute_Values(p_req_type_code => p_request_type_code,
     					     p_pricing_type_code  => p_pricing_type,
					     x_qual_ctxts_result_tbl => x_qual_contexts_result_tbl,
					     x_price_ctxts_result_tbl => x_price_contexts_result_tbl);


/*
If the attribute sourcing method is 'CUSTOM SOURCING' then user provides code to source the attributes.
User code is written in the package procedure QP_CUSTOM_SOURCE.Get_Custom_Attribute_Values and Build_Contexts program calls this procedure to pickup custom sourced attributes if the profile option 'QP_CUSTOM_SOURCED' is set to 'Y' -- GTIPPIRE
*/


  IF NVL(l_custom_sourced,'N') = 'Y' THEN
    Begin
	 qp_debug_util.tstart('GET_CUSTOM_ATTRIBUTE_VALUES','Calling the QP_CUSTOM_SOURCE package to fetch the cutom attribute values');
     Qp_Custom_Source.Get_Custom_Attribute_Values(p_req_type_code => p_request_type_code,
                                           p_pricing_type_code  => p_pricing_type,
                                           x_qual_ctxts_result_tbl => l_qual_contexts_result_tbl,
                                           x_price_ctxts_result_tbl => l_price_contexts_result_tbl);
     qp_debug_util.tstop('GET_CUSTOM_ATTRIBUTE_VALUES');
     exception
      when others then
        qp_debug_util.tstop('GET_CUSTOM_ATTRIBUTE_VALUES');
    end;

     l_count := x_qual_contexts_result_tbl.COUNT;
     LOOP
       l_count := l_count + 1;
       v_count := v_count + 1;
       EXIT WHEN v_count > l_qual_contexts_result_tbl.COUNT;
       x_qual_contexts_result_tbl(l_count).context_name :=
                                    l_qual_contexts_result_tbl(v_count).context_name;
       x_qual_contexts_result_tbl(l_count).attribute_name :=
                                    l_qual_contexts_result_tbl(v_count).attribute_name;
       x_qual_contexts_result_tbl(l_count).attribute_value :=
                                    l_qual_contexts_result_tbl(v_count).attribute_value;
     END LOOP;

     l_count := x_price_contexts_result_tbl.COUNT;
     v_count := 0;

     LOOP
       l_count := l_count + 1;
       v_count := v_count + 1;
       EXIT WHEN v_count > l_price_contexts_result_tbl.COUNT;
       x_price_contexts_result_tbl(l_count).context_name :=
                                     l_price_contexts_result_tbl(v_count).context_name;
       x_price_contexts_result_tbl(l_count).attribute_name :=
                                     l_price_contexts_result_tbl(v_count).attribute_name;
       x_price_contexts_result_tbl(l_count).attribute_value:=
                                     l_price_contexts_result_tbl(v_count).attribute_value;
    END LOOP;
  END IF;

/*
If the attribute sourcing method is 'ATTRIBUTE MAPPING' then the values for the attributes
which are used but not yet mapped must be determined.
*/

  IF Qp_Code_Control.CODE_RELEASE_LEVEL > 110508 THEN
    l_price_contexts_result_tbl.DELETE;
    l_qual_contexts_result_tbl.DELETE;

    Map_Used_But_Not_Mapped_Attrs( p_request_type_code
                                 , p_pricing_type
                                 , l_price_contexts_result_tbl
                                 , l_qual_contexts_result_tbl);

    l_count := x_qual_contexts_result_tbl.COUNT;
    v_count := 0;

    LOOP
      l_count := l_count + 1;
      v_count := v_count + 1;

      EXIT WHEN v_count > l_qual_contexts_result_tbl.COUNT;

      x_qual_contexts_result_tbl(l_count).context_name :=
                                    l_qual_contexts_result_tbl(v_count).context_name;
      x_qual_contexts_result_tbl(l_count).attribute_name :=
                                    l_qual_contexts_result_tbl(v_count).attribute_name;
      x_qual_contexts_result_tbl(l_count).attribute_value :=
                                    l_qual_contexts_result_tbl(v_count).attribute_value;
    END LOOP;

    l_count := x_price_contexts_result_tbl.COUNT;
    v_count := 0;

    LOOP
      l_count := l_count + 1;
      v_count := v_count + 1;

      EXIT WHEN v_count > l_price_contexts_result_tbl.COUNT;

      x_price_contexts_result_tbl(l_count).context_name :=
                                     l_price_contexts_result_tbl(v_count).context_name;
      x_price_contexts_result_tbl(l_count).attribute_name :=
                                     l_price_contexts_result_tbl(v_count).attribute_name;
      x_price_contexts_result_tbl(l_count).attribute_value:=
                                     l_price_contexts_result_tbl(v_count).attribute_value;
    END LOOP;

  END IF;

/*
Debug info
*/

  v_count := 0;

  LOOP

    v_count := v_count + 1;
    EXIT WHEN v_count > x_qual_contexts_result_tbl.COUNT;

    IF l_debug = Fnd_Api.G_TRUE THEN
    Oe_Debug_Pub.ADD('Context Name: ' || x_qual_contexts_result_tbl(v_count).context_name);
    Oe_Debug_Pub.ADD('Attribute Name: ' || x_qual_contexts_result_tbl(v_count).attribute_name);
    Oe_Debug_Pub.ADD('Attribute Value: ' || x_qual_contexts_result_tbl(v_count).attribute_value);

    END IF;
  END LOOP;

  v_count := 0;

  LOOP

    v_count := v_count + 1;
    EXIT WHEN v_count > x_price_contexts_result_tbl.COUNT;

    IF l_debug = Fnd_Api.G_TRUE THEN
    Oe_Debug_Pub.ADD('Context Name: ' || x_price_contexts_result_tbl(v_count).context_name);
    Oe_Debug_Pub.ADD('Attribute Name: ' || x_price_contexts_result_tbl(v_count).attribute_name);
    Oe_Debug_Pub.ADD('Attribute Value: ' || x_price_contexts_result_tbl(v_count).attribute_value);

    END IF;
  END LOOP;

  IF l_debug = Fnd_Api.G_TRUE THEN
  Oe_Debug_Pub.ADD('##### End Build Contexts #####');

  END IF;
  --setting time
  l_sourcing_end_time := dbms_utility.get_time;
  l_time_difference := (l_sourcing_end_time - l_sourcing_start_time)/100 ;

  IF l_debug = Fnd_Api.G_TRUE THEN
  Oe_Debug_Pub.ADD('##### Total Time in Build_Contexts(in sec) : ' || l_time_difference || ' #####');


  END IF;
END Build_Contexts;



/*
overloading build_contexts for AG purpose performance fix
to insert into tmp tables directly for OM Integration
changes by spgopal
*/

PROCEDURE Build_Contexts
(       p_request_type_code               IN      VARCHAR2,
        p_line_index                      IN      NUMBER,
        p_pricing_type_code               IN      VARCHAR2,
        p_price_list_validated_flag       IN      VARCHAR2,
--added for MOAC
        p_org_id                          IN NUMBER DEFAULT NULL
 )
IS

CURSOR l_line_cur IS
	SELECT line_index
	FROM qp_npreq_lines_tmp
	WHERE line_type_code = Qp_Preq_Pub.G_LINE_LEVEL
        AND   price_flag IN (Qp_Preq_Pub.G_YES, Qp_Preq_Pub.G_PHASE);

CURSOR l_order_cur IS
	SELECT line_index
	FROM qp_npreq_lines_tmp
	WHERE line_type_code = Qp_Preq_Pub.G_ORDER_LEVEL
        AND price_flag IN (Qp_Preq_Pub.G_YES, Qp_Preq_Pub.G_PHASE);



l_price_contexts_result_tbl   CONTEXTS_RESULT_TBL_TYPE;
l_qual_contexts_result_tbl    CONTEXTS_RESULT_TBL_TYPE;

v_price_contexts_result_tbl   CONTEXTS_RESULT_TBL_TYPE;
v_qual_contexts_result_tbl    CONTEXTS_RESULT_TBL_TYPE;

l_line_index_tbl 		Qp_Preq_Grp.PLS_INTEGER_TYPE;
l_line_detail_index_tbl 	Qp_Preq_Grp.PLS_INTEGER_TYPE;
l_attribute_type_tbl 		Qp_Preq_Grp.VARCHAR_TYPE;
l_context_tbl 			Qp_Preq_Grp.VARCHAR_TYPE;
l_attribute_tbl 		Qp_Preq_Grp.VARCHAR_TYPE;
l_value_from_tbl 		Qp_Preq_Grp.VARCHAR_TYPE;
l_value_to_tbl 			Qp_Preq_Grp.VARCHAR_TYPE;
l_validated_flag_tbl 		Qp_Preq_Grp.VARCHAR_TYPE;
l_ATTRIBUTE_LEVEL_tbl    	Qp_Preq_Grp.varchar_type;
l_LIST_HEADER_ID_tbl     	Qp_Preq_Grp.number_type;
l_LIST_LINE_ID_tbl       	Qp_Preq_Grp.number_type;
l_SETUP_VALUE_FROM_tbl  	Qp_Preq_Grp.varchar_type;
l_SETUP_VALUE_TO_tbl     	Qp_Preq_Grp.varchar_type;
l_GROUPING_NUMBER_tbl    	Qp_Preq_Grp.pls_integer_type;
l_NO_QUALIFIERS_IN_GRP_tbl      Qp_Preq_Grp.pls_integer_type;
l_COMPARISON_OPERATOR_TYPE_tbl  Qp_Preq_Grp.varchar_type;
l_APPLIED_FLAG_tbl              Qp_Preq_Grp.varchar_type;
l_PRICING_STATUS_CODE_tbl       Qp_Preq_Grp.varchar_type;
l_PRICING_STATUS_TEXT_tbl       Qp_Preq_Grp.varchar_type;
l_QUALIFIER_PRECEDENCE_tbl      Qp_Preq_Grp.pls_integer_type;
l_DATATYPE_tbl                  Qp_Preq_Grp.varchar_type;
l_PRICING_ATTR_FLAG_tbl         Qp_Preq_Grp.varchar_type;
l_QUALIFIER_type_tbl            Qp_Preq_Grp.varchar_type;
l_PRODUCT_UOM_CODE_TBL          Qp_Preq_Grp.varchar_type;
l_EXCLUDER_FLAG_TBL             Qp_Preq_Grp.varchar_type ;
l_PRICING_PHASE_ID_TBL          Qp_Preq_Grp.pls_integer_type ;
l_INCOMPATABILITY_GRP_CODE_TBL  Qp_Preq_Grp.varchar_type ;
l_LINE_DETAIL_type_CODE_TBL     Qp_Preq_Grp.varchar_type ;
l_MODIFIER_LEVEL_CODE_TBL       Qp_Preq_Grp.varchar_type ;
l_PRIMARY_UOM_FLAG_TBL          Qp_Preq_Grp.varchar_type ;

l_pricing_type_code VARCHAR2(1) := Fnd_Api.G_MISS_CHAR;
K PLS_INTEGER;

l_custom_sourced            VARCHAR2(1) := Fnd_Profile.VALUE('QP_CUSTOM_SOURCED');

l_sourcing_start_time NUMBER;
l_sourcing_end_time   NUMBER;
l_time_difference     NUMBER;

v_count                     NUMBER := 0;
l_count                     NUMBER := 0;
l_status_code       VARCHAR2(30);
l_status_text       VARCHAR2(240);
E_ROUTINE_ERRORS EXCEPTION;
--ignore_pricing smbalara
l_default_price_list_id NUMBER;
l_ignore VARCHAR2(1) :='N';
l_ignore_cnt NUMBER :=1;
--ignore_pricing

BEGIN

-- Set the global variable G_DEBUG_ENGINE
  Qp_Preq_Grp.Set_QP_Debug;

--added for MOAC
--Set the Global variable G_ORG_ID
G_ORG_ID := NVL(p_org_id, Qp_Util.get_org_id);

    --added for moac
    --Initialize MOAC and set org context to Org passed in nvl(p_control_rec.org_id, mo_default_org_id)

    IF Mo_Global.get_access_mode IS NULL THEN
      Mo_Global.Init('QP');
      IF G_ORG_ID IS NOT NULL THEN
        Mo_Global.set_policy_context('S', G_ORG_ID);
      END IF;
    END IF;--MO_GLOBAL

l_debug := Qp_Preq_Grp.G_DEBUG_ENGINE;

  --setting time
  l_sourcing_start_time := dbms_utility.get_time;

l_price_contexts_result_tbl.DELETE;
l_qual_contexts_result_tbl.DELETE;

v_price_contexts_result_tbl.DELETE;
v_qual_contexts_result_tbl.DELETE;

l_line_index_tbl.DELETE;
l_attribute_type_tbl.DELETE;
l_context_tbl.DELETE;
l_attribute_tbl.DELETE;
l_value_from_tbl.DELETE;
l_validated_flag_tbl.DELETE;
l_ATTRIBUTE_LEVEL_tbl.DELETE;
l_LIST_HEADER_ID_tbl.DELETE;
l_LIST_LINE_ID_tbl.DELETE;
l_SETUP_VALUE_FROM_tbl.DELETE;
l_SETUP_VALUE_TO_tbl.DELETE;
l_GROUPING_NUMBER_tbl.DELETE;
l_NO_QUALIFIERS_IN_GRP_tbl.DELETE;
l_COMPARISON_OPERATOR_TYPE_tbl.DELETE;
l_APPLIED_FLAG_tbl.DELETE;
l_PRICING_STATUS_CODE_tbl.DELETE;
l_PRICING_STATUS_TEXT_tbl.DELETE;
l_QUALIFIER_PRECEDENCE_tbl.DELETE;
l_DATATYPE_tbl.DELETE;
l_PRICING_ATTR_FLAG_tbl.DELETE;
l_QUALIFIER_type_tbl.DELETE;
l_PRODUCT_UOM_CODE_tbl.DELETE;
l_EXCLUDER_FLAG_tbl.DELETE;
l_PRICING_PHASE_ID_tbl.DELETE;
l_INCOMPATABILITY_GRP_CODE_tbl.DELETE;
l_LINE_DETAIL_type_CODE_tbl.DELETE;
l_MODIFIER_LEVEL_CODE_tbl.DELETE;
l_PRIMARY_UOM_FLAG_tbl.DELETE;

 IF l_debug = Fnd_Api.G_TRUE THEN
	Qp_Preq_Grp.ENGINE_DEBUG('Begin Build contexts');

 END IF;
K := 0;
Qp_Attr_Mapping_Pub.G_REQ_TYPE_CODE := p_request_type_code; --bug3848849

--Called Build Sourcing at line level
 IF l_debug = Fnd_Api.G_TRUE THEN
	Qp_Preq_Grp.ENGINE_DEBUG('Called Build Sourcing at line level----------');

 END IF;
l_pricing_type_code := 'L';

IF (p_pricing_type_code = 'L') THEN
	--ignore_pricing start
	IF ( NVL(Fnd_Profile.value('QP_CUSTOM_IGNORE_PRICING'),'N') = 'Y') THEN
		IF l_debug = Fnd_Api.G_TRUE THEN
			Oe_Debug_Pub.ADD('ignore_pricing : QP Profile QP_CUSTOM_IGNORE_PRICING is ON' );
		END IF;
		BEGIN
			QP_CUSTOM_IGNORE.IGNORE_ITEMLINE_FOR_PRICING(p_request_type_code,l_ignore,l_default_price_list_id);
	                IF l_ignore = 'Y' THEN   --8589909
 	                        G_IGNORE_PRICE := 'Y';
 	                ELSE
 	                        G_IGNORE_PRICE := 'N';
 	                END if;
 	                Oe_Debug_Pub.ADD('G_IGNORE_PRICE after custom procedure call: ' || G_IGNORE_PRICE);
		EXCEPTION
		WHEN OTHERS THEN
		l_ignore := 'N';
		G_IGNORE_PRICE := 'N';  --8589909
		IF l_debug = Fnd_Api.G_TRUE THEN
			Oe_Debug_Pub.ADD('ignore_pricing : Error in custom Code IGNORE_ITEMLINE_FOR_PRICING ' );
			Oe_Debug_Pub.ADD('ignore_pricing : Item will be Priced' );
		END IF;
		END;
        ELSE
		IF l_debug = Fnd_Api.G_TRUE THEN
			Oe_Debug_Pub.ADD('ignore_pricing : QP Profile QP_CUSTOM_IGNORE_PRICING is OFF');
		END IF;
	END IF;

         Qp_Build_Sourcing_Pvt.Get_Attribute_Values(p_req_type_code => p_request_type_code,
 	                                            p_pricing_type_code  => p_pricing_type_code,
 	                                            x_qual_ctxts_result_tbl => l_qual_contexts_result_tbl,
 	                                            x_price_ctxts_result_tbl => l_price_contexts_result_tbl);

 	 IF (l_ignore = 'Y' AND G_PASS_THIS_LINE = 'Y') THEN  --8589909
	        IF l_debug = Fnd_Api.G_TRUE THEN
			Oe_Debug_Pub.ADD('ignore_pricing : Line is NON PRICABLE' );
		END IF;
		l_qual_contexts_result_tbl(l_ignore_cnt).context_name := 'MODLIST';
		l_qual_contexts_result_tbl(l_ignore_cnt).attribute_name := 'QUALIFIER_ATTRIBUTE40';
		l_qual_contexts_result_tbl(l_ignore_cnt).attribute_value := l_ignore;

		l_ignore_cnt := l_ignore_cnt + 1;

		l_qual_contexts_result_tbl(l_ignore_cnt).context_name := 'MODLIST';
		l_qual_contexts_result_tbl(l_ignore_cnt).attribute_name := 'QUALIFIER_ATTRIBUTE41';
		l_qual_contexts_result_tbl(l_ignore_cnt).attribute_value := l_default_price_list_id;

		l_ignore_cnt := l_ignore_cnt + 1;

		l_qual_contexts_result_tbl(l_ignore_cnt).context_name := 'MODLIST';
		l_qual_contexts_result_tbl(l_ignore_cnt).attribute_name := 'QUALIFIER_ATTRIBUTE4';
		l_qual_contexts_result_tbl(l_ignore_cnt).attribute_value := l_default_price_list_id;

                G_IGNORE_PRICE := 'N';  --8589909
	END IF;
	--ignore_pricing end
/*
If the attribute sourcing method is 'CUSTOM SOURCING' then user provides code to source
the attributes.
User code is written in the package procedure QP_CUSTOM_SOURCE.Get_Custom_Attribute_Values and
Build_Contexts program calls this procedure to pickup custom sourced attributes if the
profile option ' QP_CUSTOM_SOURCED' is set to 'Y' -- GTIPPIRE
*/

     IF l_debug = Fnd_Api.G_TRUE THEN
     Qp_Preq_Grp.ENGINE_DEBUG('Number of qual attrs got from Get_Attribute_Values - ' || l_qual_contexts_result_tbl.COUNT );
     Qp_Preq_Grp.ENGINE_DEBUG('Number of pricing attrs got from Get_Attribute_Values - ' || l_price_contexts_result_tbl.COUNT );

     END IF;
  IF NVL(l_custom_sourced,'N') = 'Y' THEN
     IF l_debug = Fnd_Api.G_TRUE THEN
     Qp_Preq_Grp.ENGINE_DEBUG('Before Calling Custom Sourcing Package ----------');
     END IF;
  Begin
	qp_debug_util.tstart('GET_CUSTOM_ATTRIBUTE_VALUES','Calling the QP_CUSTOM_SOURCE package to fetch the cutom attribute values');
     Qp_Custom_Source.Get_Custom_Attribute_Values(p_req_type_code => p_request_type_code,
                                           p_pricing_type_code  => p_pricing_type_code,
                                           x_qual_ctxts_result_tbl => v_qual_contexts_result_tbl,
                                           x_price_ctxts_result_tbl => v_price_contexts_result_tbl);
	qp_debug_util.tstop('GET_CUSTOM_ATTRIBUTE_VALUES');
	exception
		when others then
			qp_debug_util.tstop('GET_CUSTOM_ATTRIBUTE_VALUES');
  end;
     IF l_debug = Fnd_Api.G_TRUE THEN
     Qp_Preq_Grp.ENGINE_DEBUG('After Calling Custom Sourcing Package ----------');

     Qp_Preq_Grp.ENGINE_DEBUG('Number of qual attrs got from Get_Custom_Attribute_Values - ' || v_qual_contexts_result_tbl.COUNT );
     Qp_Preq_Grp.ENGINE_DEBUG('Number of pricing attrs got from Get_Custom_Attribute_Values - ' || v_price_contexts_result_tbl.COUNT );

     END IF;
     l_count := l_qual_contexts_result_tbl.COUNT;

     LOOP
       l_count := l_count + 1;
       v_count := v_count + 1;
       EXIT WHEN v_count > v_qual_contexts_result_tbl.COUNT;
       l_qual_contexts_result_tbl(l_count).context_name :=
                                    v_qual_contexts_result_tbl(v_count).context_name;
       l_qual_contexts_result_tbl(l_count).attribute_name :=
                                    v_qual_contexts_result_tbl(v_count).attribute_name;
       l_qual_contexts_result_tbl(l_count).attribute_value :=
                                    v_qual_contexts_result_tbl(v_count).attribute_value;
     END LOOP;

     l_count := l_price_contexts_result_tbl.COUNT;
     v_count := 0;

     LOOP
       l_count := l_count + 1;
       v_count := v_count + 1;
       EXIT WHEN v_count > v_price_contexts_result_tbl.COUNT;
       l_price_contexts_result_tbl(l_count).context_name :=
                                     v_price_contexts_result_tbl(v_count).context_name;
       l_price_contexts_result_tbl(l_count).attribute_name :=
                                     v_price_contexts_result_tbl(v_count).attribute_name;
       l_price_contexts_result_tbl(l_count).attribute_value:=
                                     v_price_contexts_result_tbl(v_count).attribute_value;
    END LOOP;
  END IF;

/*
If the attribute sourcing method is 'ATTRIBUTE MAPPING' then the values for the attributes
which are used but not yet mapped must be determined. --SFIRESTO
*/

  IF Qp_Code_Control.GET_CODE_RELEASE_LEVEL > 110508 THEN
    v_price_contexts_result_tbl.DELETE;
    v_qual_contexts_result_tbl.DELETE;

    Map_Used_But_Not_Mapped_Attrs( p_request_type_code
                                 , p_pricing_type_code
                                 , v_price_contexts_result_tbl
                                 , v_qual_contexts_result_tbl);

    l_count := l_qual_contexts_result_tbl.COUNT;
    v_count := 0;

    LOOP
      l_count := l_count + 1;
      v_count := v_count + 1;

      EXIT WHEN v_count > v_qual_contexts_result_tbl.COUNT;

      l_qual_contexts_result_tbl(l_count).context_name :=
                                    v_qual_contexts_result_tbl(v_count).context_name;
      l_qual_contexts_result_tbl(l_count).attribute_name :=
                                    v_qual_contexts_result_tbl(v_count).attribute_name;
      l_qual_contexts_result_tbl(l_count).attribute_value :=
                                    v_qual_contexts_result_tbl(v_count).attribute_value;
    END LOOP;

    l_count := l_price_contexts_result_tbl.COUNT;
    v_count := 0;

    LOOP
      l_count := l_count + 1;
      v_count := v_count + 1;

      EXIT WHEN v_count > v_price_contexts_result_tbl.COUNT;

      l_price_contexts_result_tbl(l_count).context_name :=
                                     v_price_contexts_result_tbl(v_count).context_name;
      l_price_contexts_result_tbl(l_count).attribute_name :=
                                     v_price_contexts_result_tbl(v_count).attribute_name;
      l_price_contexts_result_tbl(l_count).attribute_value:=
                                     v_price_contexts_result_tbl(v_count).attribute_value;
    END LOOP;

  END IF;


--FOR j IN l_line_cur
--LOOP
	FOR i IN 1..l_price_contexts_result_tbl.COUNT
	LOOP
	--sourcing product attributes
	K := K + 1;

		l_line_index_tbl(K) := p_line_index;
		IF l_price_contexts_result_tbl(i).context_name =
						Qp_Preq_Pub.G_ITEM_CONTEXT
		THEN
		l_attribute_type_tbl(K) := Qp_Preq_Pub.G_PRODUCT_TYPE;
		ELSE
		l_attribute_type_tbl(K) := Qp_Preq_Pub.G_PRICING_TYPE;
		END IF;
		l_context_tbl(K) := l_price_contexts_result_tbl(i).context_name;
		l_attribute_tbl(K) := l_price_contexts_result_tbl(i).attribute_name;
		l_value_from_tbl(K) := l_price_contexts_result_tbl(i).attribute_value;

		l_validated_flag_tbl(K) := 'N';
		/**************   Defaulting for Java Engine    ********************/
                l_ATTRIBUTE_LEVEL_tbl(K) :=  Qp_Preq_Pub.G_LINE_LEVEL;
                l_LIST_HEADER_ID_tbl(K) :=   NULL;
                l_LIST_LINE_ID_tbl(K) :=     NULL;
                l_SETUP_VALUE_FROM_tbl(K) := NULL;
                l_SETUP_VALUE_TO_tbl(K) :=   NULL;
                l_GROUPING_NUMBER_tbl(K) :=  NULL;
                l_NO_QUALIFIERS_IN_GRP_tbl(K) := NULL;
                l_COMPARISON_OPERATOR_TYPE_tbl(K) := NULL;
                l_APPLIED_FLAG_tbl(K) := Qp_Preq_Pub.G_LIST_NOT_APPLIED;
                l_PRICING_STATUS_CODE_tbl(K) := Qp_Preq_Pub.G_STATUS_UNCHANGED;
                l_PRICING_STATUS_TEXT_tbl(K) := NULL;
                l_QUALIFIER_PRECEDENCE_tbl(K) := NULL;
                l_DATATYPE_tbl(K) :=  NULL;
                l_PRICING_ATTR_FLAG_tbl(K) :=  Qp_Preq_Pub.G_YES;
                l_QUALIFIER_TYPE_tbl(K) :=  NULL;
                l_PRODUCT_UOM_CODE_tbl(K) := NULL;
                l_EXCLUDER_FLAG_tbl(K) := NULL;
                l_PRICING_PHASE_ID_tbl(K) := NULL;
                l_INCOMPATABILITY_GRP_CODE_tbl(K) := NULL;
                l_LINE_DETAIL_TYPE_CODE_tbl(K) := NULL;
                l_MODIFIER_LEVEL_CODE_tbl(K) := NULL;
                l_PRIMARY_UOM_FLAG_tbl(K) :=   NULL;

	END LOOP;

	FOR i IN 1..l_qual_contexts_result_tbl.COUNT
	LOOP
	--sourcing qualifier attributes
	K := K + 1;
		l_line_index_tbl(K) := p_line_index;
		l_attribute_type_tbl(K) := Qp_Preq_Pub.G_QUALIFIER_TYPE;
		l_context_tbl(K) := l_qual_contexts_result_tbl(i).context_name;
		l_attribute_tbl(K) := l_qual_contexts_result_tbl(i).attribute_name;
		l_value_from_tbl(K) := l_qual_contexts_result_tbl(i).attribute_value;

		/**************   Defaulting for Java Engine    ********************/
                l_ATTRIBUTE_LEVEL_tbl(K) :=  Qp_Preq_Pub.G_LINE_LEVEL;
                l_LIST_HEADER_ID_tbl(K) :=   NULL;
                l_LIST_LINE_ID_tbl(K) :=     NULL;
                l_SETUP_VALUE_FROM_tbl(K) := NULL;
                l_SETUP_VALUE_TO_tbl(K) :=   NULL;
                l_GROUPING_NUMBER_tbl(K) :=  NULL;
                l_NO_QUALIFIERS_IN_GRP_tbl(K) := NULL;
                l_COMPARISON_OPERATOR_TYPE_tbl(K) := NULL;
                l_APPLIED_FLAG_tbl(K) := Qp_Preq_Pub.G_LIST_NOT_APPLIED;
                l_PRICING_STATUS_CODE_tbl(K) := Qp_Preq_Pub.G_STATUS_UNCHANGED;
                l_PRICING_STATUS_TEXT_tbl(K) := NULL;
                l_QUALIFIER_PRECEDENCE_tbl(K) := NULL;
                l_DATATYPE_tbl(K) :=  NULL;
                l_PRICING_ATTR_FLAG_tbl(K) :=  Qp_Preq_Pub.G_YES;
                l_QUALIFIER_TYPE_tbl(K) :=  NULL;
                l_PRODUCT_UOM_CODE_tbl(K) := NULL;
                l_EXCLUDER_FLAG_tbl(K) := NULL;
                l_PRICING_PHASE_ID_tbl(K) := NULL;
                l_INCOMPATABILITY_GRP_CODE_tbl(K) := NULL;
                l_LINE_DETAIL_TYPE_CODE_tbl(K) := NULL;
                l_MODIFIER_LEVEL_CODE_tbl(K) := NULL;
                l_PRIMARY_UOM_FLAG_tbl(K) :=   NULL;

		--changes for bug 2049125 Agreement Price lists must have
		--validated flag 'Y'
                -- validated flag is populated based on p_price_list_validated_flag input variable
                IF l_qual_contexts_result_tbl(i).context_name ='MODLIST'
		AND l_qual_contexts_result_tbl(i).Attribute_Name =
				'QUALIFIER_ATTRIBUTE4'
		THEN

                        IF Oe_Order_Pub.G_Line.agreement_id IS NOT NULL
			AND Oe_Order_Pub.G_Line.agreement_id <> Fnd_Api.g_miss_num
                        AND NVL(p_price_list_validated_flag,'Y') = 'Y'
			THEN
                                l_validated_flag_tbl(K) := 'Y';
                        ELSIF NVL(p_price_list_validated_flag,'N') = 'N' THEN
                                l_validated_flag_tbl(K) := 'N';
                        ELSIF p_price_list_validated_flag = 'Y' THEN
                                l_validated_flag_tbl(K) := 'Y';
                        END IF;
                ELSE
                                l_validated_flag_tbl(K) := 'N';
                END IF;


	END LOOP;
--END LOOP;

END IF;

--Called Build Sourcing at header level
 IF l_debug = Fnd_Api.G_TRUE THEN
	Qp_Preq_Grp.ENGINE_DEBUG('Called Build Sourcing at header level----------');

 END IF;
v_count  := 0;
l_count  := 0;

l_price_contexts_result_tbl.DELETE;
l_qual_contexts_result_tbl.DELETE;

v_price_contexts_result_tbl.DELETE;
v_qual_contexts_result_tbl.DELETE;

l_pricing_type_code := 'H';

IF (p_pricing_type_code = 'H') THEN

	Qp_Build_Sourcing_Pvt.Get_Attribute_Values(p_req_type_code => p_request_type_code,
						   p_pricing_type_code  => p_pricing_type_code,
						   x_qual_ctxts_result_tbl => l_qual_contexts_result_tbl,
						   x_price_ctxts_result_tbl => l_price_contexts_result_tbl);

     IF l_debug = Fnd_Api.G_TRUE THEN
     Qp_Preq_Grp.ENGINE_DEBUG('Number of qual attrs got from Get_Attribute_Values - ' || l_qual_contexts_result_tbl.COUNT );
     Qp_Preq_Grp.ENGINE_DEBUG('Number of pricing attrs got from Get_Attribute_Values - ' || l_price_contexts_result_tbl.COUNT );

     END IF;
/*
If the attribute sourcing method is 'CUSTOM SOURCING' then user provides code to source
the attributes.
User code is written in the package procedure QP_CUSTOM_SOURCE.Get_Custom_Attribute_Values and
Build_Contexts program calls this procedure to pickup custom sourced attributes if the
profile option ' QP_CUSTOM_SOURCED' is set to 'Y' -- GTIPPIRE
*/

  IF NVL(l_custom_sourced,'N') = 'Y' THEN
     IF l_debug = Fnd_Api.G_TRUE THEN
     Qp_Preq_Grp.ENGINE_DEBUG('Before Calling Custom Sourcing Package ----------');
     END IF;
   Begin
	qp_debug_util.tstart('GET_CUSTOM_ATTRIBUTE_VALUES','Calling the QP_CUSTOM_SOURCE package to fetch the cutom attribute values');
     Qp_Custom_Source.Get_Custom_Attribute_Values(p_req_type_code => p_request_type_code,
                                           p_pricing_type_code  => p_pricing_type_code,
                                           x_qual_ctxts_result_tbl => v_qual_contexts_result_tbl,
                                           x_price_ctxts_result_tbl => v_price_contexts_result_tbl);
	qp_debug_util.tstop('GET_CUSTOM_ATTRIBUTE_VALUES');
	exception
		when others then
			qp_debug_util.tstop('GET_CUSTOM_ATTRIBUTE_VALUES');
   end;

     IF l_debug = Fnd_Api.G_TRUE THEN
     Qp_Preq_Grp.ENGINE_DEBUG('After Calling Custom Sourcing Package ----------');

     Qp_Preq_Grp.ENGINE_DEBUG('Number of qual attrs got from Get_Custom_Attribute_Values - ' || v_qual_contexts_result_tbl.COUNT );
     Qp_Preq_Grp.ENGINE_DEBUG('Number of pricing attrs got from Get_Custom_Attribute_Values - ' || v_price_contexts_result_tbl.COUNT );

     END IF;
     l_count := l_qual_contexts_result_tbl.COUNT;

     LOOP
       l_count := l_count + 1;
       v_count := v_count + 1;
       EXIT WHEN v_count > v_qual_contexts_result_tbl.COUNT;
       l_qual_contexts_result_tbl(l_count).context_name :=
                                    v_qual_contexts_result_tbl(v_count).context_name;
       l_qual_contexts_result_tbl(l_count).attribute_name :=
                                    v_qual_contexts_result_tbl(v_count).attribute_name;
       l_qual_contexts_result_tbl(l_count).attribute_value :=
                                    v_qual_contexts_result_tbl(v_count).attribute_value;
     END LOOP;

     l_count := l_price_contexts_result_tbl.COUNT;
     v_count := 0;

     LOOP
       l_count := l_count + 1;
       v_count := v_count + 1;
       EXIT WHEN v_count > v_price_contexts_result_tbl.COUNT;
       l_price_contexts_result_tbl(l_count).context_name :=
                                     v_price_contexts_result_tbl(v_count).context_name;
       l_price_contexts_result_tbl(l_count).attribute_name :=
                                     v_price_contexts_result_tbl(v_count).attribute_name;
       l_price_contexts_result_tbl(l_count).attribute_value:=
                                     v_price_contexts_result_tbl(v_count).attribute_value;
    END LOOP;
  END IF;

/*
If the attribute sourcing method is 'ATTRIBUTE MAPPING' then the values for the attributes
which are used but not yet mapped must be determined. --SFIRESTO
*/

  IF Qp_Code_Control.GET_CODE_RELEASE_LEVEL > 110508 THEN
    v_price_contexts_result_tbl.DELETE;
    v_qual_contexts_result_tbl.DELETE;

    Map_Used_But_Not_Mapped_Attrs( p_request_type_code
                                 , p_pricing_type_code
                                 , v_price_contexts_result_tbl
                                 , v_qual_contexts_result_tbl);

    l_count := l_qual_contexts_result_tbl.COUNT;
    v_count := 0;

    LOOP
      l_count := l_count + 1;
      v_count := v_count + 1;

      EXIT WHEN v_count > v_qual_contexts_result_tbl.COUNT;

      l_qual_contexts_result_tbl(l_count).context_name :=
                                    v_qual_contexts_result_tbl(v_count).context_name;
      l_qual_contexts_result_tbl(l_count).attribute_name :=
                                    v_qual_contexts_result_tbl(v_count).attribute_name;
      l_qual_contexts_result_tbl(l_count).attribute_value :=
                                    v_qual_contexts_result_tbl(v_count).attribute_value;
    END LOOP;

    l_count := l_price_contexts_result_tbl.COUNT;
    v_count := 0;

    LOOP
      l_count := l_count + 1;
      v_count := v_count + 1;

      EXIT WHEN v_count > v_price_contexts_result_tbl.COUNT;

      l_price_contexts_result_tbl(l_count).context_name :=
                                     v_price_contexts_result_tbl(v_count).context_name;
      l_price_contexts_result_tbl(l_count).attribute_name :=
                                     v_price_contexts_result_tbl(v_count).attribute_name;
      l_price_contexts_result_tbl(l_count).attribute_value:=
                                     v_price_contexts_result_tbl(v_count).attribute_value;
    END LOOP;

  END IF;


--FOR j IN l_order_cur
--LOOP
	FOR i IN 1..l_price_contexts_result_tbl.COUNT
	LOOP
	--sourcing product attributes
	K := K + 1;

		l_line_index_tbl(K) := p_line_index;
		IF l_price_contexts_result_tbl(i).context_name =
						Qp_Preq_Pub.G_ITEM_CONTEXT
		THEN
		l_attribute_type_tbl(K) := Qp_Preq_Pub.G_PRODUCT_TYPE;
		ELSE
		l_attribute_type_tbl(K) := Qp_Preq_Pub.G_PRICING_TYPE;
		END IF;
		l_context_tbl(K) := l_price_contexts_result_tbl(i).context_name;
		l_attribute_tbl(K) := l_price_contexts_result_tbl(i).attribute_name;
		l_value_from_tbl(K) := l_price_contexts_result_tbl(i).attribute_value;
		l_validated_flag_tbl(K) := 'N';
		/**************   Defaulting for Java Engine    ********************/
                l_ATTRIBUTE_LEVEL_tbl(K) :=  Qp_Preq_Pub.G_LINE_LEVEL;
                l_LIST_HEADER_ID_tbl(K) :=   NULL;
                l_LIST_LINE_ID_tbl(K) :=     NULL;
                l_SETUP_VALUE_FROM_tbl(K) := NULL;
                l_SETUP_VALUE_TO_tbl(K) :=   NULL;
                l_GROUPING_NUMBER_tbl(K) :=  NULL;
                l_NO_QUALIFIERS_IN_GRP_tbl(K) := NULL;
                l_COMPARISON_OPERATOR_TYPE_tbl(K) := NULL;
                l_APPLIED_FLAG_tbl(K) := Qp_Preq_Pub.G_LIST_NOT_APPLIED;
                l_PRICING_STATUS_CODE_tbl(K) := Qp_Preq_Pub.G_STATUS_UNCHANGED;
                l_PRICING_STATUS_TEXT_tbl(K) := NULL;
                l_QUALIFIER_PRECEDENCE_tbl(K) := NULL;
                l_DATATYPE_tbl(K) :=  NULL;
                l_PRICING_ATTR_FLAG_tbl(K) :=  Qp_Preq_Pub.G_YES;
                l_QUALIFIER_TYPE_tbl(K) :=  NULL;
                l_PRODUCT_UOM_CODE_tbl(K) := NULL;
                l_EXCLUDER_FLAG_tbl(K) := NULL;
                l_PRICING_PHASE_ID_tbl(K) := NULL;
                l_INCOMPATABILITY_GRP_CODE_tbl(K) := NULL;
                l_LINE_DETAIL_TYPE_CODE_tbl(K) := NULL;
                l_MODIFIER_LEVEL_CODE_tbl(K) := NULL;
                l_PRIMARY_UOM_FLAG_tbl(K) :=   NULL;

	END LOOP;

	FOR i IN 1..l_qual_contexts_result_tbl.COUNT
	LOOP
	--sourcing qualifier attributes
	K := K + 1;
		l_line_index_tbl(K) := p_line_index;
		l_attribute_type_tbl(K) := Qp_Preq_Pub.G_QUALIFIER_TYPE;
		l_context_tbl(K) := l_qual_contexts_result_tbl(i).context_name;
		l_attribute_tbl(K) := l_qual_contexts_result_tbl(i).attribute_name;
		l_value_from_tbl(K) := l_qual_contexts_result_tbl(i).attribute_value;

        /**************   Defaulting for Java Engine    ********************/
                l_ATTRIBUTE_LEVEL_tbl(K) :=  Qp_Preq_Pub.G_LINE_LEVEL;
        	l_LIST_HEADER_ID_tbl(K) :=   NULL;
        	l_LIST_LINE_ID_tbl(K) :=     NULL;
        	l_SETUP_VALUE_FROM_tbl(K) := NULL;
        	l_SETUP_VALUE_TO_tbl(K) :=   NULL;
        	l_GROUPING_NUMBER_tbl(K) :=  NULL;
        	l_NO_QUALIFIERS_IN_GRP_tbl(K) := NULL;
        	l_COMPARISON_OPERATOR_TYPE_tbl(K) := NULL;
        	l_APPLIED_FLAG_tbl(K) := Qp_Preq_Pub.G_LIST_NOT_APPLIED;
        	l_PRICING_STATUS_CODE_tbl(K) := Qp_Preq_Pub.G_STATUS_UNCHANGED;
        	l_PRICING_STATUS_TEXT_tbl(K) := NULL;
        	l_QUALIFIER_PRECEDENCE_tbl(K) := NULL;
        	l_DATATYPE_tbl(K) :=  NULL;
        	l_PRICING_ATTR_FLAG_tbl(K) :=  Qp_Preq_Pub.G_YES;
        	l_QUALIFIER_TYPE_tbl(K) :=  NULL;
        	l_PRODUCT_UOM_CODE_tbl(K) := NULL;
        	l_EXCLUDER_FLAG_tbl(K) := NULL;
        	l_PRICING_PHASE_ID_tbl(K) := NULL;
        	l_INCOMPATABILITY_GRP_CODE_tbl(K) := NULL;
        	l_LINE_DETAIL_TYPE_CODE_tbl(K) := NULL;
        	l_MODIFIER_LEVEL_CODE_tbl(K) := NULL;
        	l_PRIMARY_UOM_FLAG_tbl(K) :=   NULL;


		--changes for bug 2049125 Agreement Price lists must have
		--validated flag 'Y'
                IF l_qual_contexts_result_tbl(i).context_name ='MODLIST'
		AND l_qual_contexts_result_tbl(i).Attribute_Name =
				'QUALIFIER_ATTRIBUTE4'
		THEN

                        IF Oe_Order_Pub.G_Line.agreement_id IS NOT NULL
			AND Oe_Order_Pub.G_Line.agreement_id <> Fnd_Api.g_miss_num
			THEN
                                l_validated_flag_tbl(K) := 'Y';
                        ELSE
                                l_validated_flag_tbl(K) := 'N';
                        END IF;
                ELSE
                                l_validated_flag_tbl(K) := 'N';
                END IF;

	END LOOP;
--END LOOP;

END IF;

IF l_debug = Fnd_Api.G_TRUE THEN

	Qp_Preq_Grp.ENGINE_DEBUG('Printing line attributes ----------');
FOR i IN 1..l_line_index_tbl.COUNT
LOOP
 IF l_debug = Fnd_Api.G_TRUE THEN
	Qp_Preq_Grp.ENGINE_DEBUG('line index '||l_line_index_tbl(i));
	Qp_Preq_Grp.ENGINE_DEBUG('attribute type '||l_attribute_type_tbl(i));
	Qp_Preq_Grp.ENGINE_DEBUG('context '||l_context_tbl(i));
	Qp_Preq_Grp.ENGINE_DEBUG('attribute '||l_attribute_tbl(i));
	Qp_Preq_Grp.ENGINE_DEBUG('value from '||l_value_from_tbl(i));
	Qp_Preq_Grp.ENGINE_DEBUG('validated flag '||l_validated_flag_tbl(i));
	Qp_Preq_Grp.ENGINE_DEBUG('-----------------------------------------');
 END IF;
END LOOP;
END IF; --debug true


IF l_line_index_tbl.COUNT > 0
THEN
BEGIN
 IF l_debug = Fnd_Api.G_TRUE THEN
	Qp_Preq_Grp.ENGINE_DEBUG('Tata Inserting line attributes ----------');
 END IF;

IF Qp_Java_Engine_Util_Pub.Java_Engine_Running = 'N' THEN
 IF l_debug = Fnd_Api.G_TRUE THEN
	Qp_Preq_Grp.ENGINE_DEBUG('Java Engine not Installed ----------');
 END IF;

 FORALL i IN l_line_index_tbl.FIRST..l_line_index_tbl.LAST
   INSERT INTO qp_npreq_line_attrs_tmp
                (line_index,
                 attribute_level,
                 attribute_type,
                 context,
                 attribute,
                 value_from,
                 validated_flag,
                 applied_flag,
                 pricing_status_code,
                 pricing_attr_flag
                )
   VALUES       (l_line_index_tbl(i),
                 Qp_Preq_Pub.G_LINE_LEVEL,
                 l_attribute_type_tbl(i),
                 l_context_tbl(i),
                 l_attribute_tbl(i),
                 l_value_from_tbl(i),
		 l_validated_flag_tbl(i),
                 Qp_Preq_Pub.G_LIST_NOT_APPLIED,
                 Qp_Preq_Pub.G_STATUS_UNCHANGED,
                 Qp_Preq_Pub.G_YES
                );
 ELSE -- Java Engine path added by yangli
   IF l_debug = Fnd_Api.G_TRUE THEN
	Qp_Preq_Grp.ENGINE_DEBUG('Java Engine Installed path----------');
   END IF;
   /*QP_PREQ_GRP.INSERT_LINE_ATTRS_AT( l_line_index_tbl,
                                        QP_PREQ_PUB.G_LINE_LEVEL,
                                        l_attribute_type_tbl,
                                        l_context_tbl,
                                        l_attribute_tbl,
                                        l_value_from_tbl,
                                        l_validated_flag_tbl,
                                        QP_PREQ_PUB.G_LIST_NOT_APPLIED,
                                        QP_PREQ_PUB.G_STATUS_UNCHANGED,
                                        QP_PREQ_PUB.G_YES,
					l_status_code      ,
					l_status_text       );
   */

   --bug 3113427
   FOR i IN l_line_index_tbl.first..l_line_index_tbl.last
   LOOP
	l_LINE_DETAIL_INDEX_tbl (i) := NULL;
	l_value_to_tbl (i) := NULL;
   END LOOP;

   Qp_Preq_Grp.INSERT_LINE_ATTRS2 (     p_LINE_INDEX_tbl => l_line_index_tbl,
					p_LINE_DETAIL_INDEX_tbl => l_line_Detail_index_tbl,
					p_ATTRIBUTE_LEVEL_tbl=> l_ATTRIBUTE_LEVEL_tbl,
                                        p_ATTRIBUTE_TYPE_tbl => l_attribute_type_tbl,
        				p_LIST_HEADER_ID_tbl=> l_LIST_HEADER_ID_tbl,
        				p_LIST_LINE_ID_tbl=> l_LIST_LINE_ID_tbl,
                                        p_CONTEXT_tbl => l_context_tbl,
                                        p_ATTRIBUTE_tbl => l_attribute_tbl,
                                        p_VALUE_FROM_tbl => l_value_from_tbl,
        				p_SETUP_VALUE_FROM_tbl=> l_SETUP_VALUE_FROM_tbl,
					p_VALUE_TO_tbl => l_value_to_tbl,
        				p_SETUP_VALUE_TO_tbl=> l_SETUP_VALUE_TO_tbl,
        				p_GROUPING_NUMBER_tbl=> l_GROUPING_NUMBER_tbl,
        				p_NO_QUALIFIERS_IN_GRP_tbl=> l_NO_QUALIFIERS_IN_GRP_tbl,
        				p_COMPARISON_OPERATOR_TYPE_tbl=> l_COMPARISON_OPERATOR_TYPE_tbl,
                                        p_VALIDATED_FLAG_tbl => l_validated_flag_tbl,
        				p_APPLIED_FLAG_tbl=> l_APPLIED_FLAG_tbl,
        				p_PRICING_STATUS_CODE_tbl=> l_PRICING_STATUS_CODE_tbl,
        				p_PRICING_STATUS_TEXT_tbl=> l_PRICING_STATUS_TEXT_tbl,
        				p_QUALIFIER_PRECEDENCE_tbl=> l_QUALIFIER_PRECEDENCE_tbl,
        				p_DATATYPE_tbl=> l_DATATYPE_tbl,
        				p_PRICING_ATTR_FLAG_tbl=> l_PRICING_ATTR_FLAG_tbl,
        				p_QUALIFIER_TYPE_tbl=> l_QUALIFIER_TYPE_tbl,
        				p_PRODUCT_UOM_CODE_tbl=> l_PRODUCT_UOM_CODE_tbl,
        				p_EXCLUDER_FLAG_tbl=> l_EXCLUDER_FLAG_tbl,
        				p_PRICING_PHASE_ID_tbl=> l_PRICING_PHASE_ID_tbl,
        				p_INCOMPATABILITY_GRP_CODE_tbl=> l_INCOMPATABILITY_GRP_CODE_tbl,
        				p_LINE_DETAIL_TYPE_CODE_tbl=> l_LINE_DETAIL_TYPE_CODE_tbl,
        				p_MODIFIER_LEVEL_CODE_tbl=> l_MODIFIER_LEVEL_CODE_tbl,
        				p_PRIMARY_UOM_FLAG_tbl=> l_PRIMARY_UOM_FLAG_tbl,
					x_status_code => l_status_code,
					x_status_text => l_status_text);
     IF l_status_code = Fnd_Api.G_RET_STS_ERROR THEN
        RAISE E_ROUTINE_ERRORS;
     END IF;
 END IF;

 IF l_debug = Fnd_Api.G_TRUE THEN
	Qp_Preq_Grp.ENGINE_DEBUG('End Inserting line attributes ----------');
 END IF;
EXCEPTION
  WHEN E_ROUTINE_ERRORS THEN
   IF l_debug = Fnd_Api.G_TRUE THEN
  Qp_Preq_Grp.engine_debug('QP_ATTR_MAPPING_PUB:Bld Contxt Insert LINE_ATTR '||''||l_status_text);
   END IF;
  WHEN OTHERS THEN
  IF l_debug = Fnd_Api.G_TRUE THEN
  Qp_Preq_Grp.engine_debug('QP_ATTR_MAPPING_PUB:Bld Contxt Insert LINE_ATTR '||' '||SQLERRM);
  END IF;
END;

END IF;

  IF l_debug = Fnd_Api.G_TRUE THEN
  Qp_Preq_Grp.ENGINE_DEBUG('End Build contexts');

  END IF;
  --setting time
  l_sourcing_end_time := dbms_utility.get_time;
  l_time_difference := (l_sourcing_end_time - l_sourcing_start_time)/100 ;

  IF l_debug = Fnd_Api.G_TRUE THEN
  Oe_Debug_Pub.ADD('##### Total Time in Build_Contexts(in sec) : ' || l_time_difference || ' #####');

  END IF;
EXCEPTION
WHEN OTHERS THEN
 IF l_debug = Fnd_Api.G_TRUE THEN
	Qp_Preq_Grp.ENGINE_DEBUG('Exception in QP_ATTR_MAPPING_PUB.Build_context '||SQLERRM);

 END IF;
END Build_Contexts;



PROCEDURE Get_User_Item_Pricing_Attribs
(	p_request_type_code	IN	VARCHAR2
,	p_item_id	IN	VARCHAR2
,	p_user_attribs_tbl  OUT	NOCOPY USER_ATTRIBUTE_TBL_TYPE
)
IS

    v_item_category     VARCHAR2(60);
    l_found             VARCHAR2(1);
    v_pricing_attr_ctxt VARCHAR2(240); --4932085, 4960278
    v_pricing_attr      VARCHAR2(240); --4932085, 4960278
    l_condition_id      VARCHAR2(60);
    l_context_name      VARCHAR2(240); --4932085, 4960278
    l_attr_def_condition_id      VARCHAR2(60);
    v_count		BINARY_INTEGER := 1;
    l_context_code            VARCHAR2(30);
    l_context_type            VARCHAR2(30);
    l_segment_code            VARCHAR2(30);
    l_segment_mapping_column  VARCHAR2(30);

    CURSOR l_pricing_attribs IS
    SELECT DISTINCT pricing_attribute_context, pricing_attribute
    FROM  qp_pricing_attributes
    WHERE product_attribute = 'PRICING_ATTRIBUTE1'
    AND	product_attribute_context = 'ITEM'
    AND	product_attr_value = p_item_id
    AND	pricing_attribute_context IS NOT NULL
    AND	pricing_attribute IS NOT NULL;

    CURSOR l_cond_cursor(p_pricing_attr VARCHAR2) IS
    SELECT c.condition_id, d.attr_def_condition_id
    FROM oe_def_conditions a, oe_def_condn_elems b,
    oe_def_attr_condns c, oe_def_attr_def_rules d, qp_price_req_sources e
    WHERE a.database_object_name LIKE 'QP%'
    AND a.condition_id = b.condition_id
    AND b.attribute_code = 'SRC_SYSTEM_CODE'
    AND b.value_string = e.source_system_code
    AND e.request_type_code = p_request_type_code
    AND b.condition_id = c.condition_id
    AND c.attribute_code = p_pricing_attr
    AND c.attr_def_condition_id = d.attr_def_condition_id;

    CURSOR l_cond_cursor_new(p_pricing_attr VARCHAR2) IS
    SELECT DISTINCT qpseg.segment_code, qpseg.segment_mapping_column,
           qpcon.prc_context_code, qpcon.prc_context_type
    FROM   qp_segments_b qpseg, qp_prc_contexts_b qpcon,
           qp_pte_segments qppteseg, qp_pte_request_types_b qpptereq
    WHERE  qpseg.segment_id = qppteseg.segment_id AND
           qpseg.segment_mapping_column = p_pricing_attr AND
           qpseg.prc_context_id = qpcon.prc_context_id AND
           qpcon.enabled_flag = 'Y' AND
           qpptereq.request_type_code = p_request_type_code AND
           qpptereq.pte_code = qppteseg.pte_code AND
           qppteseg.user_sourcing_method = 'USER ENTERED';

BEGIN

    l_debug := Qp_Preq_Grp.G_DEBUG_ENGINE;
    --FND_PROFILE.GET('QP_ATTRIBUTE_MANAGER_INSTALLED',G_ATTRMGR_INSTALLED);
    G_ATTRMGR_INSTALLED := Qp_Util.Attrmgr_Installed;

    IF NVL(G_ATTRMGR_INSTALLED,'N') = 'N' THEN
       OPEN l_pricing_attribs;

       LOOP

    	   FETCH l_pricing_attribs INTO v_pricing_attr_ctxt, v_pricing_attr;
    	   EXIT WHEN l_pricing_attribs%NOTFOUND;

    IF l_debug = Fnd_Api.G_TRUE THEN
	   Oe_Debug_Pub.ADD('Item Context: ' || v_pricing_attr_ctxt);
	   Oe_Debug_Pub.ADD('Item Attribute: ' || v_pricing_attr);

    END IF;
	   l_found := 0;

           OPEN l_cond_cursor(v_pricing_attr);

           LOOP

               FETCH l_cond_cursor INTO l_condition_id, l_attr_def_condition_id;
	       EXIT WHEN l_cond_cursor%NOTFOUND;

	       SELECT value_string
	       INTO   l_context_name
	       FROM   oe_def_condn_elems
	       WHERE  condition_id = l_condition_id
	       AND    attribute_code = 'PRICING_CONTEXT';

        IF l_debug = Fnd_Api.G_TRUE THEN
	       Oe_Debug_Pub.ADD('Sourced Context: ' || l_context_name);
	       Oe_Debug_Pub.ADD('Compared Context: ' || v_pricing_attr_ctxt);
        END IF;

	       IF l_context_name =  v_pricing_attr_ctxt THEN

	          l_found := 1;
                  IF l_debug = Fnd_Api.G_TRUE THEN
                  Oe_Debug_Pub.ADD('Found : ' || l_found);

                  END IF;
	       END IF;


	   END LOOP;
	   CLOSE l_cond_cursor;

	   IF l_found = 0 THEN

       IF l_debug = Fnd_Api.G_TRUE THEN
	      Oe_Debug_Pub.ADD('Not Found context: ' || v_pricing_attr_ctxt);
	      Oe_Debug_Pub.ADD('Not Found attribute: ' || v_pricing_attr);
       END IF;
	      p_user_attribs_tbl(v_count).context_name := v_pricing_attr_ctxt;
	      p_user_attribs_tbl(v_count).attribute_name := v_pricing_attr;
              v_count := v_count + 1;

	   END IF;

       END LOOP;
       CLOSE l_pricing_attribs;
    ELSIF NVL(G_ATTRMGR_INSTALLED,'N') = 'Y' THEN

       OPEN l_pricing_attribs;

       LOOP

    	   FETCH l_pricing_attribs INTO v_pricing_attr_ctxt, v_pricing_attr;
    	   EXIT WHEN l_pricing_attribs%NOTFOUND;

    IF l_debug = Fnd_Api.G_TRUE THEN
	   Oe_Debug_Pub.ADD('Item Context: ' || v_pricing_attr_ctxt);
	   Oe_Debug_Pub.ADD('Item Attribute: ' || v_pricing_attr);

    END IF;
	   l_found := 0;

           OPEN l_cond_cursor_new(v_pricing_attr);

           LOOP

               FETCH l_cond_cursor_new INTO l_segment_code, l_segment_mapping_column,
                                            l_context_code,l_context_type;
	       EXIT WHEN l_cond_cursor_new%NOTFOUND;

        IF l_debug = Fnd_Api.G_TRUE THEN
	       Oe_Debug_Pub.ADD('Sourced Context: ' || l_context_code);
	       Oe_Debug_Pub.ADD('Compared Context: ' || v_pricing_attr_ctxt);
        END IF;

	       IF l_context_code =  v_pricing_attr_ctxt THEN

	          l_found := 1;
                  IF l_debug = Fnd_Api.G_TRUE THEN
                  Oe_Debug_Pub.ADD('Found : ' || l_found);

                  END IF;
	       END IF;

	   END LOOP;
	   CLOSE l_cond_cursor_new;

	   IF l_found = 1 THEN

       IF l_debug = Fnd_Api.G_TRUE THEN
	      Oe_Debug_Pub.ADD('Found User Entered context: ' || v_pricing_attr_ctxt);
	      Oe_Debug_Pub.ADD('Found User Entered attribute: ' || v_pricing_attr);
       END IF;
	      p_user_attribs_tbl(v_count).context_name := v_pricing_attr_ctxt;
	      p_user_attribs_tbl(v_count).attribute_name := v_pricing_attr;
              v_count := v_count + 1;

	   END IF;

       END LOOP;
       CLOSE l_pricing_attribs;
    END IF;
END Get_User_Item_Pricing_Attribs;

PROCEDURE Get_User_Item_Pricing_Attribs
(	p_request_type_code	IN	VARCHAR2
,	p_user_attribs_tbl  OUT	NOCOPY USER_ATTRIBUTE_TBL_TYPE
)
IS

    l_found             VARCHAR2(1);
    v_pricing_attr_ctxt VARCHAR2(240); --4932085, 4960278
    v_pricing_attr      VARCHAR2(240); --4932085, 4960278
    l_condition_id      VARCHAR2(60);
    l_context_name      VARCHAR2(240); --4932085, 4960278
    l_attr_def_condition_id      VARCHAR2(60);
    v_count		BINARY_INTEGER := 1;
    l_context_code            VARCHAR2(30);
    l_context_type            VARCHAR2(30);
    l_segment_code            VARCHAR2(30);
    l_segment_mapping_column  VARCHAR2(30);

    CURSOR l_pricing_attribs IS
    SELECT DISTINCT pricing_attribute_context, pricing_attribute
    FROM   qp_pricing_attributes
    WHERE  pricing_attribute_context IS NOT NULL
    AND pricing_attribute_context NOT IN ('VOLUME','ITEM')
    AND	   pricing_attribute_context <> Fnd_Api.G_MISS_CHAR
    AND	   pricing_attribute <> Fnd_Api.G_MISS_CHAR
    AND	   pricing_attribute IS NOT NULL;

    CURSOR l_cond_cursor(p_pricing_attr VARCHAR2) IS
    SELECT c.condition_id, d.attr_def_condition_id
    FROM oe_def_conditions a, oe_def_condn_elems b,
    oe_def_attr_condns c, oe_def_attr_def_rules d, qp_price_req_sources e
    WHERE a.database_object_name LIKE 'QP%'
    AND a.condition_id = b.condition_id
    AND b.attribute_code = 'SRC_SYSTEM_CODE'
    AND b.value_string = e.source_system_code
    AND e.request_type_code = p_request_type_code
    AND b.condition_id = c.condition_id
    AND c.attribute_code = p_pricing_attr
    AND c.attr_def_condition_id = d.attr_def_condition_id;

    CURSOR l_cond_cursor_new(p_pricing_attr VARCHAR2) IS
    SELECT DISTINCT qpseg.segment_code, qpseg.segment_mapping_column,
           qpcon.prc_context_code, qpcon.prc_context_type
    FROM   qp_segments_b qpseg, qp_prc_contexts_b qpcon,
           qp_pte_segments qppteseg, qp_pte_request_types_b qpptereq
    WHERE  qpseg.segment_id = qppteseg.segment_id AND
           qpseg.segment_mapping_column = p_pricing_attr AND
           qpseg.prc_context_id = qpcon.prc_context_id AND
           qpcon.enabled_flag = 'Y' AND
           qpptereq.request_type_code = p_request_type_code AND
           qpptereq.pte_code = qppteseg.pte_code AND
           qppteseg.user_sourcing_method = 'USER ENTERED';

BEGIN

    l_debug := Qp_Preq_Grp.G_DEBUG_ENGINE;
    --FND_PROFILE.GET('QP_ATTRIBUTE_MANAGER_INSTALLED',G_ATTRMGR_INSTALLED);
    G_ATTRMGR_INSTALLED := Qp_Util.Attrmgr_Installed;

    IF NVL(G_ATTRMGR_INSTALLED,'N') = 'N' THEN
       OPEN l_pricing_attribs;

       LOOP

    	   FETCH l_pricing_attribs INTO v_pricing_attr_ctxt, v_pricing_attr;
    	   EXIT WHEN l_pricing_attribs%NOTFOUND;

    IF l_debug = Fnd_Api.G_TRUE THEN
	   Oe_Debug_Pub.ADD('Pricing Context: ' || NVL(v_pricing_attr_ctxt,'Jeff'));
	   Oe_Debug_Pub.ADD('Pricing Attribute: ' || v_pricing_attr);

    END IF;
	   l_found := 0;

	   OPEN l_cond_cursor(v_pricing_attr);

	   LOOP

  	       FETCH l_cond_cursor INTO l_condition_id, l_attr_def_condition_id;
	       EXIT WHEN l_cond_cursor%NOTFOUND;

	       SELECT value_string
	       INTO   l_context_name
	       FROM   oe_def_condn_elems
	       WHERE  condition_id = l_condition_id
	       AND    attribute_code = 'PRICING_CONTEXT';

        IF l_debug = Fnd_Api.G_TRUE THEN
	       Oe_Debug_Pub.ADD('Sourced Context: ' || l_context_name);
	       Oe_Debug_Pub.ADD('Compared Context: ' || v_pricing_attr_ctxt);
        END IF;

	       IF l_context_name =  v_pricing_attr_ctxt THEN

	          l_found := 1;
           IF l_debug = Fnd_Api.G_TRUE THEN
	          Oe_Debug_Pub.ADD('Found : ' || l_found);

           END IF;
	       END IF;


	   END LOOP;
	   CLOSE l_cond_cursor;

	   IF l_found = 0 THEN

       IF l_debug = Fnd_Api.G_TRUE THEN
	      Oe_Debug_Pub.ADD('Not Found context: ' || v_pricing_attr_ctxt);
	      Oe_Debug_Pub.ADD('Not Found attribute: ' || v_pricing_attr);
       END IF;
	      p_user_attribs_tbl(v_count).context_name := v_pricing_attr_ctxt;
	      p_user_attribs_tbl(v_count).attribute_name := v_pricing_attr;
              v_count := v_count + 1;

	   END IF;
       END LOOP;
       CLOSE l_pricing_attribs;

       v_count := v_count - 1;
       IF l_debug = Fnd_Api.G_TRUE THEN
       Oe_Debug_Pub.ADD('Number of Non-sourced attributes : ' || v_count);
       END IF;
    ELSIF NVL(G_ATTRMGR_INSTALLED,'N') = 'Y' THEN
       OPEN l_pricing_attribs;

       LOOP

    	   FETCH l_pricing_attribs INTO v_pricing_attr_ctxt, v_pricing_attr;
    	   EXIT WHEN l_pricing_attribs%NOTFOUND;

    IF l_debug = Fnd_Api.G_TRUE THEN
	   Oe_Debug_Pub.ADD('Pricing Context: ' || NVL(v_pricing_attr_ctxt,'Jeff'));
	   Oe_Debug_Pub.ADD('Pricing Attribute: ' || v_pricing_attr);

    END IF;
	   l_found := 0;

	   OPEN l_cond_cursor_new(v_pricing_attr);

	   LOOP

               FETCH l_cond_cursor_new INTO l_segment_code, l_segment_mapping_column,
                                            l_context_code,l_context_type;
	       EXIT WHEN l_cond_cursor_new%NOTFOUND;

        IF l_debug = Fnd_Api.G_TRUE THEN
	       Oe_Debug_Pub.ADD('Sourced Context: ' || l_context_code);
	       Oe_Debug_Pub.ADD('Compared Context: ' || v_pricing_attr_ctxt);
        END IF;

	       IF l_context_code =  v_pricing_attr_ctxt THEN

	          l_found := 1;
           IF l_debug = Fnd_Api.G_TRUE THEN
	          Oe_Debug_Pub.ADD('Found : ' || l_found);

           END IF;
	       END IF;

	   END LOOP;
	   CLOSE l_cond_cursor_new;

	   IF l_found = 1 THEN

       IF l_debug = Fnd_Api.G_TRUE THEN
	      Oe_Debug_Pub.ADD('Found user entered context: ' || v_pricing_attr_ctxt);
	      Oe_Debug_Pub.ADD('Found user entered attribute: ' || v_pricing_attr);
       END IF;
	      p_user_attribs_tbl(v_count).context_name := v_pricing_attr_ctxt;
	      p_user_attribs_tbl(v_count).attribute_name := v_pricing_attr;
              v_count := v_count + 1;

	   END IF;
       END LOOP;
       CLOSE l_pricing_attribs;

       v_count := v_count - 1;
       IF l_debug = Fnd_Api.G_TRUE THEN
       Oe_Debug_Pub.ADD('Number of Non-sourced attributes : ' || v_count);
       END IF;
    END IF;

END Get_User_Item_Pricing_Attribs;


PROCEDURE Get_User_Item_Pricing_Contexts
(	p_request_type_code	IN	VARCHAR2
,	p_user_attribs_tbl  OUT	NOCOPY USER_ATTRIBUTE_TBL_TYPE
)
IS

    l_found             VARCHAR2(1);
    v_pricing_attr_ctxt VARCHAR2(60);
    l_condition_id      VARCHAR2(60);
    l_context_name      VARCHAR2(60);
    v_count		BINARY_INTEGER := 1;
    l_context_code      VARCHAR2(30);
    l_context_type      VARCHAR2(30);

    CURSOR l_pricing_contexts IS
    SELECT descriptive_flex_context_code
    FROM   fnd_descr_flex_contexts
    WHERE  enabled_flag = 'Y'
    AND    application_id = 661
    AND    descriptive_flexfield_name = 'QP_ATTR_DEFNS_PRICING';


    CURSOR l_sourced_contexts IS
    SELECT DISTINCT b.condition_id
    FROM oe_def_conditions a, oe_def_condn_elems b, qp_price_req_sources c,
         oe_def_attr_condns d
    WHERE a.database_object_name LIKE 'QP%'
    AND a.condition_id = b.condition_id
    AND b.attribute_code = 'SRC_SYSTEM_CODE'
    AND b.value_string = c.source_system_code
    AND c.request_type_code = p_request_type_code
    AND d.condition_id = a.condition_id
    AND d.attribute_code LIKE 'PRICING_ATTRIBUTE%';

    CURSOR l_non_sourced_contexts IS
    SELECT DISTINCT qpcon.prc_context_code, qpcon.prc_context_type
    FROM   qp_segments_b qpseg, qp_prc_contexts_b qpcon,
           qp_pte_segments qppteseg, qp_pte_request_types_b qpptereq
    WHERE qpseg.segment_id = qppteseg.segment_id AND
          qpseg.prc_context_id = qpcon.prc_context_id AND
          qpcon.enabled_flag = 'Y' AND
          qpcon.PRC_CONTEXT_TYPE IN ('PRICING_ATTRIBUTE', 'PRODUCT') AND
          qpptereq.request_type_code = p_request_type_code AND
          qpptereq.pte_code = qppteseg.pte_code AND
          qppteseg.user_sourcing_method = 'USER ENTERED';
BEGIN

    l_debug := Qp_Preq_Grp.G_DEBUG_ENGINE;
    --FND_PROFILE.GET('QP_ATTRIBUTE_MANAGER_INSTALLED',G_ATTRMGR_INSTALLED);
    G_ATTRMGR_INSTALLED := Qp_Util.Attrmgr_Installed;

    IF NVL(G_ATTRMGR_INSTALLED,'N') = 'N' THEN
       OPEN l_pricing_contexts;

       LOOP

    	   FETCH l_pricing_contexts INTO v_pricing_attr_ctxt;
    	   EXIT WHEN l_pricing_contexts%NOTFOUND;

    IF l_debug = Fnd_Api.G_TRUE THEN
	   Oe_Debug_Pub.ADD('Pricing Context: ' || NVL(v_pricing_attr_ctxt,'Jeff'));

    END IF;
	   l_found := 0;

	   OPEN l_sourced_contexts;

	   LOOP

	       FETCH l_sourced_contexts INTO l_condition_id;
	       EXIT WHEN l_sourced_contexts%NOTFOUND;

	       SELECT value_string
	       INTO   l_context_name
	       FROM   oe_def_condn_elems
	       WHERE  condition_id = l_condition_id
	       AND    attribute_code = 'PRICING_CONTEXT';

        IF l_debug = Fnd_Api.G_TRUE THEN
	       Oe_Debug_Pub.ADD('Sourced Context: ' || l_context_name);
	       Oe_Debug_Pub.ADD('Compared Context: ' || v_pricing_attr_ctxt);
        END IF;

               IF (l_context_name =  v_pricing_attr_ctxt) THEN
	          l_found := 1;
           IF l_debug = Fnd_Api.G_TRUE THEN
	          Oe_Debug_Pub.ADD('Found : ' || l_found);
           END IF;
	       END IF;

	   END LOOP;
	   CLOSE l_sourced_contexts;

	   IF l_found = 0 THEN
       IF l_debug = Fnd_Api.G_TRUE THEN
	      Oe_Debug_Pub.ADD('Not Found context: ' || v_pricing_attr_ctxt);
       END IF;
	      p_user_attribs_tbl(v_count).context_name := v_pricing_attr_ctxt;
              v_count := v_count + 1;
	   END IF;
       END LOOP;
       CLOSE l_pricing_contexts;

       v_count := v_count - 1;
       IF l_debug = Fnd_Api.G_TRUE THEN
       Oe_Debug_Pub.ADD('Number of Non-sourced contexts : ' || v_count);
       END IF;
    ELSIF NVL(G_ATTRMGR_INSTALLED,'N') = 'Y' THEN
       OPEN l_non_sourced_contexts;

       LOOP

           FETCH l_non_sourced_contexts INTO l_context_code, l_context_type;
           EXIT WHEN l_non_sourced_contexts%NOTFOUND;
    IF l_debug = Fnd_Api.G_TRUE THEN
	   Oe_Debug_Pub.ADD('User Entered Context: ' || l_context_code);
    END IF;
	   p_user_attribs_tbl(v_count).context_name := l_context_code;
           v_count := v_count + 1;
       END LOOP;
       CLOSE l_non_sourced_contexts;

       v_count := v_count - 1;
       IF l_debug = Fnd_Api.G_TRUE THEN
       Oe_Debug_Pub.ADD('Number of Non-sourced contexts : ' || v_count);
       END IF;
    END IF;


END Get_User_Item_Pricing_Contexts;

FUNCTION Is_Attribute_Used(p_attribute_context IN VARCHAR2, p_attribute_code IN VARCHAR2) RETURN VARCHAR2
IS

x_out	VARCHAR2(1) := 'N';

BEGIN

   BEGIN

   SELECT 'Y'
   INTO x_out
   FROM   qp_price_formula_lines
   WHERE  pricing_attribute_context = p_attribute_context
   AND    pricing_attribute = p_attribute_code
   AND    ROWNUM < 2;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        BEGIN
            SELECT /*+ index(qp_pricing_attributes qp_pricing_attributes_n4) */ 'Y'
            INTO   x_out
            FROM   qp_pricing_attributes
            WHERE  pricing_attribute_context = p_attribute_context
            AND    pricing_attribute = p_attribute_code
            AND    ROWNUM < 2;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 x_out := 'N';
        END;

   END;

   RETURN  x_out;

END Is_Attribute_Used;

/*************************************************************************
***********************Fix for bug 2491269********************************
**********Changed lines API pass only dependent lines*********************
*************************************************************************/

PROCEDURE Check_line_group_items(p_pricing_type_code IN VARCHAR2) IS
--l_prod_exists_tbl QP_PREQ_GRP.FLAG_TYPE;
l_prod_exists VARCHAR2(1) := 'N';
l_all_items_exist VARCHAR2(1) := 'N';
BEGIN
        BEGIN
        SELECT 'Y' INTO l_all_items_exist
        FROM qp_event_phases evt, qp_adv_mod_products item
                WHERE INSTR(G_PRICING_EVENT, evt.pricing_event_code) > 0
                AND item.pricing_phase_id = evt.pricing_phase_id
                AND item.product_attribute = 'PRICING_ATTRIBUTE3'
                AND item.product_attr_value = 'ALL'
                AND ROWNUM = 1;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                l_all_items_exist := 'N';
        WHEN OTHERS THEN
                l_all_items_exist := 'N';
                IF l_debug = Fnd_Api.G_TRUE THEN
                Oe_Debug_Pub.ADD('In exception l_all_items_exist:'||SQLERRM);
                END IF;
        END;

        IF l_debug = Fnd_Api.G_TRUE THEN
        Oe_Debug_Pub.ADD('In check_line_group_items l_all_items_exist '
                ||l_all_items_exist);
        Oe_Debug_Pub.ADD('In check_line_group_items G_Product_Attr_tbl.COUNT '
                ||G_Product_Attr_tbl.COUNT);
        Oe_Debug_Pub.ADD('In check_line_group_items p_pricing_type_code '
	||p_pricing_type_code||' G_CHECK_LINE_FLAG '||G_CHECK_LINE_FLAG);
        END IF;
        IF G_CHECK_LINE_FLAG = 'N'
        OR p_pricing_type_code = 'H'
        OR l_all_items_exist = 'Y'
        THEN
                G_PASS_THIS_LINE := 'Y';
        ELSIF G_Product_Attr_tbl.COUNT = 0
        THEN
                G_PASS_THIS_LINE := 'N';
        ELSE
                FOR i IN G_Product_Attr_tbl.FIRST..G_Product_Attr_tbl.LAST
                LOOP
                        IF l_debug = Fnd_Api.G_TRUE THEN
                        Oe_Debug_Pub.ADD('Looping thru prod attr '
                        ||'attribute '||G_Product_Attr_tbl(i).attribute_name
                        ||' value '||G_Product_Attr_tbl(i).attribute_value);
                        END IF;
                        BEGIN
                        SELECT 'Y' INTO l_prod_exists
                        FROM qp_adv_mod_products item, qp_event_phases evt
                        WHERE INSTR(G_PRICING_EVENT, evt.pricing_event_code) > 0
                        AND item.pricing_phase_id = evt.pricing_phase_id
                        AND item.product_attribute =
                                G_Product_Attr_tbl(i).attribute_name
                        AND item.product_attr_value =
                                G_Product_Attr_tbl(i).attribute_value
                        AND ROWNUM = 1;
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                NULL;
                        WHEN OTHERS THEN
                        IF l_debug = Fnd_Api.G_TRUE THEN
                        Oe_Debug_Pub.ADD('In exception G_PASS_THIS_LINE:'
                        ||SQLERRM);
                        END IF;
                        END;
                        IF l_debug = Fnd_Api.G_TRUE THEN
                        Oe_Debug_Pub.ADD('In check_line_group_items loop '
                        ||l_prod_exists);
                        END IF;
                        IF l_prod_exists = 'Y'
                        THEN
                                EXIT;
                        END IF;
                END LOOP;
                IF l_prod_exists = 'Y'
                THEN
                        G_PASS_THIS_LINE := 'Y';
                        IF l_debug = Fnd_Api.G_TRUE THEN
                        Oe_Debug_Pub.ADD('Check_line_group_items '
                                   ||G_PASS_THIS_LINE);
                        END IF;
                ELSE
                        G_PASS_THIS_LINE := 'N';
                        IF l_debug = Fnd_Api.G_TRUE THEN
                        Oe_Debug_Pub.ADD('Check_line_group_items '
                                   ||G_PASS_THIS_LINE);
                        END IF;
                END IF;

        END IF;
                                IF l_debug = Fnd_Api.G_TRUE THEN
                                Oe_Debug_Pub.ADD('Check_line_group_items '
                                ||'Pass Line: '||G_PASS_THIS_LINE);
                                END IF;
EXCEPTION
WHEN OTHERS THEN
IF l_debug = Fnd_Api.G_TRUE THEN
Oe_Debug_Pub.ADD('Error in QP_ATTR_MAPPING_PUB.Check_line_group_items '||SQLERRM);
END IF;
G_PASS_THIS_LINE := 'Y';
END Check_line_group_items;

--Overloaded in the pl/sql path for changed lines linegroup item dependency
PROCEDURE Build_Contexts
(       p_request_type_code             IN      VARCHAR2
,       p_pricing_type                  IN      VARCHAR2
,       p_check_line_flag               IN      VARCHAR2
,       p_pricing_event                 IN      VARCHAR2
--added for MOAC
,       p_org_id                          IN NUMBER DEFAULT NULL
,       x_price_contexts_result_tbl     OUT NOCOPY    CONTEXTS_RESULT_TBL_TYPE
,       x_qual_contexts_result_tbl      OUT NOCOPY    CONTEXTS_RESULT_TBL_TYPE
,       x_pass_line                     OUT NOCOPY        VARCHAR2
) IS
BEGIN
--delete all to start with
G_PRODUCT_ATTR_TBL.DELETE;
G_CHECK_LINE_FLAG := p_check_line_flag;
G_PRICING_EVENT := p_pricing_event||',';
IF l_debug = Fnd_Api.G_TRUE THEN
Oe_Debug_Pub.ADD('p_check_line_flag '||p_check_line_flag);
Oe_Debug_Pub.ADD('p_pricing_event '||p_pricing_event);
Oe_Debug_Pub.ADD('p_pricing_type_code '||p_pricing_type);
END IF;
Qp_Attr_Mapping_Pub.G_REQ_TYPE_CODE := p_request_type_code; --bug3848849
        Build_Contexts
        (       p_request_type_code => p_request_type_code
        ,       p_pricing_type => p_pricing_type
        --added for MOAC
        ,       p_org_id       => p_org_id
        ,       x_price_contexts_result_tbl => x_price_contexts_result_tbl
        ,       x_qual_contexts_result_tbl => x_qual_contexts_result_tbl
        );

        IF x_price_contexts_result_tbl.COUNT > 0 THEN
        FOR i IN x_price_contexts_result_tbl.FIRST..x_price_contexts_result_tbl.LAST
        LOOP
                IF l_debug = Fnd_Api.G_TRUE THEN
                Oe_Debug_Pub.ADD('After sourcing ret '||x_price_contexts_result_tbl(i).context_name||' '||x_price_contexts_result_tbl(i).attribute_name||' '||x_price_contexts_result_tbl(i).attribute_value);
                END IF;
        END LOOP;
        END IF;


        --Indicates to caller that they need to pass this line
        x_pass_line := G_PASS_THIS_LINE;
        IF l_debug = Fnd_Api.G_TRUE THEN
        Oe_Debug_Pub.ADD('Build_contexts pass this line '||x_pass_line);

        END IF;
EXCEPTION
WHEN OTHERS THEN
        IF l_debug = Fnd_Api.G_TRUE THEN
        Oe_Debug_Pub.ADD('Exception in QP_ATTR_MAPPING_PUB.Build_context'||SQLERRM);
        END IF;
END Build_Contexts;

/*Fix for bug 2491269
Overloaded for enhancing performance to pass all/changed lines to
the pricing engine to tell caller whether or not to pass given line*/
PROCEDURE Build_Contexts
(       p_request_type_code               IN      VARCHAR2,
        p_line_index                      IN      NUMBER,
        p_check_line_flag                 IN      VARCHAR2,
        p_pricing_event                   IN      VARCHAR2,
        p_pricing_type_code               IN      VARCHAR2,
        p_price_list_validated_flag       IN      VARCHAR2,
--added for MOAC
        p_org_id                          IN NUMBER DEFAULT NULL,
        x_pass_line                       OUT     NOCOPY        VARCHAR2
 )
IS
BEGIN
G_CHECK_LINE_FLAG := p_check_line_flag;
G_PRICING_EVENT := p_pricing_event||',';
IF l_debug = Fnd_Api.G_TRUE THEN
Oe_Debug_Pub.ADD('p_check_line_flag '||p_check_line_flag);
Oe_Debug_Pub.ADD('p_pricing_event '||p_pricing_event);
Oe_Debug_Pub.ADD('p_pricing_type_code '||p_pricing_type_code);

END IF;
Qp_Attr_Mapping_Pub.G_REQ_TYPE_CODE := p_request_type_code; --bug3848849
        Build_Contexts
        (       p_request_type_code => p_request_type_code,
                p_line_index    => p_line_index,
                p_pricing_type_code     => p_pricing_type_code,
                p_price_list_validated_flag => p_price_list_validated_flag,
                --added for MOAC
                p_org_id => p_org_id
        );
        --Indicates to caller that they need to pass this line
        x_pass_line := G_PASS_THIS_LINE;
        IF l_debug = Fnd_Api.G_TRUE THEN
        Oe_Debug_Pub.ADD('Build_contexts pass this line '||x_pass_line);

        END IF;
EXCEPTION
WHEN OTHERS THEN
        IF l_debug = Fnd_Api.G_TRUE THEN
        Oe_Debug_Pub.ADD('Exception in QP_ATTR_MAPPING_PUB.Build_context'||SQLERRM);
        END IF;
END Build_Contexts;


FUNCTION Get_API_Value
(       p_src_api_call     IN             VARCHAR2
,       p_successful       IN OUT NOCOPY  BOOLEAN
)  RETURN VARCHAR2
IS

  l_sql_stmt  VARCHAR2(2060);
  x_return VARCHAR2(240);

BEGIN
  p_successful := TRUE;
  --dbms_output.put_line('*****Going Dynamic for******: ' || p_src_api_call);

   l_sql_stmt := 'BEGIN QP_Attr_Mapping_PUB.G_Temp_Value := ' || p_src_api_call || ';' || ' END;';

  --dbms_output.put_line(l_sql_stmt);
  EXECUTE IMMEDIATE l_sql_stmt ;

  x_return := Qp_Attr_Mapping_Pub.G_Temp_Value;

  --dbms_output.put_line('Return Value:' || x_return);

  IF x_return = Fnd_Api.G_MISS_NUM THEN
        RETURN NULL;
  ELSE
	RETURN x_return;
  END IF;

  EXCEPTION
  	WHEN VALUE_ERROR THEN
      		IF x_return = Fnd_Api.G_MISS_CHAR THEN
        		RETURN NULL;
      		ELSE
			RETURN x_return;
      		END IF;
        WHEN NO_DATA_FOUND THEN
          RETURN NULL;
   	WHEN OTHERS THEN
          g_err_mesg := SQLERRM;
          p_successful:= FALSE;
          RETURN NULL;

END Get_API_Value;



FUNCTION Get_API_MultiValue
(       p_src_mult_api_call  IN             VARCHAR2
,       p_successful         IN OUT NOCOPY  BOOLEAN
) RETURN Qp_Attr_Mapping_Pub.t_MultiRecord
IS

  l_sql_stmt VARCHAR2(2060);
  x_return   Qp_Attr_Mapping_Pub.t_MultiRecord;

  BEGIN
    p_successful := TRUE;

  --dbms_output.put_line('Going Dynamic for: ' || p_src_mult_api_call);

    l_sql_stmt := 'BEGIN QP_Attr_Mapping_PUB.G_Temp_MultiValue := '|| p_src_mult_api_call ||'; END;';
  --dbms_output.put_line(l_sql_stmt);

    EXECUTE IMMEDIATE l_sql_stmt;
  --dbms_output.put_line('Count for Multirec: ' || QP_Attr_Mapping_PUB.G_Temp_MultiValue.count);

    x_return := Qp_Attr_Mapping_Pub.G_Temp_MultiValue;

    RETURN x_return;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      Put_Line('No_Data_Found Exception');
      x_return(1) := NULL;
      RETURN x_return;
    WHEN OTHERS THEN
      g_err_mesg := SQLERRM;
      p_successful := FALSE;
      x_return(1) := NULL;
      RETURN x_return;


END Get_API_MultiValue;


FUNCTION Get_Profile_Option_Value
(	p_profile_option     IN             VARCHAR2
,       p_successful         IN OUT NOCOPY  BOOLEAN
) RETURN VARCHAR2
IS

BEGIN

  p_successful := TRUE;
  RETURN Fnd_Profile.value(p_profile_option);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    g_err_mesg := SQLERRM;
    p_successful := FALSE;
    RETURN NULL;

END Get_Profile_Option_Value;


FUNCTION Get_System_Variable
(	p_sys_variable     IN             VARCHAR2
,       p_successful       IN OUT NOCOPY  BOOLEAN
) RETURN VARCHAR2
IS

  l_sql_stmt VARCHAR2(100);
  x_return   VARCHAR2(240);

BEGIN

  p_successful := TRUE;
  l_sql_stmt := 'SELECT ' ||  p_sys_variable || ' FROM DUAL';

  EXECUTE IMMEDIATE l_sql_stmt INTO x_return;

  RETURN x_return;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    g_err_mesg := SQLERRM;
    p_successful := FALSE;
    RETURN NULL;

END Get_System_Variable;

PROCEDURE Add_to_Contexts_Results_Table
(    p_results_tbl       IN OUT NOCOPY  CONTEXTS_RESULT_TBL_TYPE
,    p_index             IN   NUMBER
,    p_context_name      IN   VARCHAR2
,    p_attribute_name    IN   VARCHAR2
,    p_attribute_value   IN   VARCHAR2
)

IS

BEGIN

  p_results_tbl(p_index).context_name := p_context_name;
--  oe_debug_pub.add('Context(' || p_index || '): ' || p_results_tbl(p_index).context_name);

  p_results_tbl(p_index).attribute_name := p_attribute_name;
--  oe_debug_pub.add('Attribute Name(' || p_index || '): ' || p_results_tbl(p_index).attribute_name);

  p_results_tbl(p_index).attribute_value := p_attribute_value;
--  oe_debug_pub.add('Attribute Value(' || p_index || '): ' || p_results_tbl(p_index).attribute_value);

END Add_to_Contexts_Results_Table;

PROCEDURE Map_Used_But_Not_Mapped_Attrs
(       p_request_type_code               IN             VARCHAR2
,       p_pricing_type                    IN             VARCHAR2
,       x_price_contexts_result_tbl       OUT NOCOPY     CONTEXTS_RESULT_TBL_TYPE
,       x_qual_contexts_result_tbl        OUT NOCOPY     CONTEXTS_RESULT_TBL_TYPE
)

IS

  l_pricing_type       VARCHAR2(30);
  l_attribute_value    VARCHAR2(240);
  l_attribute_mvalue   Qp_Attr_Mapping_Pub.t_MultiRecord;
  l_context_name       qp_prc_contexts_b.prc_context_code%TYPE;
  l_context_type       qp_prc_contexts_b.prc_context_type%TYPE;
  l_attribute_name     qp_segments_b.segment_mapping_column%TYPE;
  l_src_type           qp_attribute_sourcing.user_sourcing_type%TYPE;
  l_value_string       qp_attribute_sourcing.user_value_string%TYPE;
  l_qual_count         BINARY_INTEGER := 0;
  l_price_count        BINARY_INTEGER := 0;
  l_count              BINARY_INTEGER := 0;
  l_index              BINARY_INTEGER := 0;
  l_successful         BOOLEAN := TRUE;

  CURSOR l_ctxts_new(p_request_type_code VARCHAR2, p_sourcing_level VARCHAR2) IS
    SELECT qpseg.segment_mapping_column,
      qpsour.user_sourcing_type src_type,
      qpsour.user_value_string value_string,
      qpcon.prc_context_code context_code,
      qpcon.prc_context_type context_type
    FROM
      qp_segments_b qpseg,
      qp_attribute_sourcing qpsour,
      qp_prc_contexts_b qpcon,
      qp_pte_request_types_b qpreq,
      qp_pte_segments qppseg
    WHERE
      qpsour.segment_id = qpseg.segment_id
      AND qpsour.attribute_sourcing_level = p_sourcing_level
      AND qpsour.enabled_flag = 'Y'
      AND qppseg.sourcing_status = 'N'
      AND qppseg.used_in_setup = 'Y'
      AND qppseg.user_sourcing_method = 'ATTRIBUTE MAPPING'
      AND qpsour.request_type_code = p_request_type_code
      AND qpseg.prc_context_id = qpcon.prc_context_id
      AND qpreq.request_type_code = qpsour.request_type_code
      AND qppseg.pte_code = qpreq.pte_code
      AND qppseg.segment_id = qpsour.segment_id
      AND qppseg.sourcing_enabled = 'Y'
      AND qpcon.prc_context_type IN ('PRICING_ATTRIBUTE', 'PRODUCT','QUALIFIER');

BEGIN

  IF g_dynamic_mapping_needed  = 'N' THEN
    RETURN;
  END IF;

  IF p_pricing_type = 'L' THEN
    l_pricing_type := 'LINE';
  ELSIF p_pricing_type = 'H' THEN
    l_pricing_type := 'ORDER';
  END IF;

  OPEN l_ctxts_new(p_request_type_code, l_pricing_type);

  LOOP
   -- l_count := l_count + 1;  --7323926

    FETCH l_ctxts_new INTO
      l_attribute_name,
      l_src_type,
      l_value_string,
      l_context_name,
      l_context_type;
    EXIT WHEN l_ctxts_new%NOTFOUND;

     g_dynamic_mapping_count := g_dynamic_mapping_count + 1;  -- 7323926

    IF l_debug = Fnd_Api.G_TRUE THEN
    Oe_Debug_Pub.ADD('Context = ' || l_context_name);
    Oe_Debug_Pub.ADD('Attribute = ' || l_attribute_name);

    END IF;
    l_successful := TRUE;

    IF l_src_type = 'API' THEN
      --dbms_output.put_line('Before Calling Get_API_Value');
      l_attribute_value := Get_API_Value(l_value_string, l_successful);
      IF l_debug = Fnd_Api.G_TRUE THEN
      Oe_Debug_Pub.ADD('Attr Name = '|| l_value_string);
      Oe_Debug_Pub.ADD('Attr Value = '|| l_attribute_value);

      END IF;
    ELSIF l_src_type = 'API_MULTIREC' THEN
      --dbms_output.put_line('Before Calling Get_MULTIREC_API_Value');
      l_attribute_mvalue := Get_API_MultiValue(l_value_string, l_successful);
      IF l_debug = Fnd_Api.G_TRUE THEN
      Oe_Debug_Pub.ADD('Multirec API = '|| l_value_string);

      END IF;
    ELSIF l_src_type = 'PROFILE_OPTION' THEN
      --dbms_output.put_line('Before Calling Get_Profile_Option_Value');
      l_attribute_value := Get_Profile_Option_Value(l_value_string, l_successful);
      IF l_debug = Fnd_Api.G_TRUE THEN
      Oe_Debug_Pub.ADD('Profile = '|| l_value_string);
      Oe_Debug_Pub.ADD('Profile Value = '|| l_attribute_value);

      END IF;
    ELSIF l_src_type = 'SYSTEM' THEN
      --dbms_output.put_line('Before Calling Get_System_Variable');
      l_attribute_value := Get_System_Variable(l_value_string, l_successful);
      IF l_debug = Fnd_Api.G_TRUE THEN
      Oe_Debug_Pub.ADD('System Variable = ' || l_value_string);
      Oe_Debug_Pub.ADD('System Variable Value = ' || l_attribute_value);

      END IF;
    ELSIF l_src_type = 'CONSTANT' THEN
      l_attribute_value := l_value_string;
      IF l_debug = Fnd_Api.G_TRUE THEN
      Oe_Debug_Pub.ADD('Constant = ' || l_value_string);

      END IF;
    ELSE
      IF l_debug = Fnd_Api.G_TRUE THEN
      Oe_Debug_Pub.ADD('Invalid source type');

      END IF;
    END IF;

    IF (l_attribute_value IS NOT NULL) AND (l_src_type <> 'API_MULTIREC') THEN

      IF l_context_type = 'QUALIFIER' THEN

        l_qual_count := l_qual_count + 1;

        Add_to_Contexts_Results_Table(x_qual_contexts_result_tbl, l_qual_count, l_context_name, l_attribute_name, l_attribute_value);

        IF l_debug = Fnd_Api.G_TRUE THEN
        Oe_Debug_Pub.ADD('Context(' || l_qual_count || '): ' || x_qual_contexts_result_tbl(l_qual_count).context_name);
        Oe_Debug_Pub.ADD('SRC Type(' || l_qual_count || '): ' || l_src_type);
        Oe_Debug_Pub.ADD('SRC Value(' || l_qual_count || '): ' || l_attribute_value);
        Oe_Debug_Pub.ADD('Attribute Name(' || l_qual_count || '): ' || x_qual_contexts_result_tbl(l_qual_count).attribute_name);
        Oe_Debug_Pub.ADD('Attribute Value(' || l_qual_count || '): ' || x_qual_contexts_result_tbl(l_qual_count).attribute_value);
        Oe_Debug_Pub.ADD('------------------------------');

        END IF;
      ELSIF l_context_type = 'PRICING_ATTRIBUTE' OR l_context_type = 'PRODUCT' THEN

        l_price_count := l_price_count + 1;

        Add_to_Contexts_Results_Table(x_price_contexts_result_tbl, l_price_count, l_context_name, l_attribute_name, l_attribute_value);

        IF l_debug = Fnd_Api.G_TRUE THEN
        Oe_Debug_Pub.ADD('Context(' || l_price_count || '): ' || x_price_contexts_result_tbl(l_price_count).context_name);
        Oe_Debug_Pub.ADD('SRC Type(' || l_price_count || '): ' || l_src_type);
        Oe_Debug_Pub.ADD('SRC Value(' || l_price_count || '): ' || l_attribute_value);
        Oe_Debug_Pub.ADD('Attribute Name(' || l_price_count || '): ' || x_price_contexts_result_tbl(l_price_count).attribute_name);
        Oe_Debug_Pub.ADD('Attribute Value(' || l_price_count || '): ' || x_price_contexts_result_tbl(l_price_count).attribute_value);
        Oe_Debug_Pub.ADD('------------------------------');

        END IF;
      ELSE
        IF l_debug = Fnd_Api.G_TRUE THEN
        Oe_Debug_Pub.ADD('Context type invalid');

        END IF;
      END IF;

    ELSIF (l_attribute_mvalue IS NOT NULL) AND (l_src_type = 'API_MULTIREC')  THEN

      IF l_debug = Fnd_Api.G_TRUE THEN
      Oe_Debug_Pub.ADD('Found a MULTIREC for context type: ' || l_context_type);

      END IF;

      IF (l_attribute_mvalue.COUNT <> 0) AND (l_attribute_mvalue(1) IS NOT NULL) THEN

        l_index := 0;

        LOOP
          l_index := l_index + 1;

          IF l_context_type = 'QUALIFIER' THEN

            l_qual_count := l_qual_count + 1;

            Add_to_Contexts_Results_Table(x_qual_contexts_result_tbl,l_qual_count,l_context_name,l_attribute_name,l_attribute_mvalue(l_index));

            IF l_debug = Fnd_Api.G_TRUE THEN
            Oe_Debug_Pub.ADD('Context(' || l_qual_count || '): ' || x_qual_contexts_result_tbl(l_qual_count).context_name);
            Oe_Debug_Pub.ADD('SRC Type(' || l_qual_count || '): ' || l_src_type);
            Oe_Debug_Pub.ADD('SRC Value(' || l_qual_count || '): ' || l_attribute_value);
            Oe_Debug_Pub.ADD('Attribute Name(' || l_qual_count || '): ' || x_qual_contexts_result_tbl(l_qual_count).attribute_name);
            Oe_Debug_Pub.ADD('Attribute Value(' || l_qual_count || '): ' || x_qual_contexts_result_tbl(l_qual_count).attribute_value);
            Oe_Debug_Pub.ADD('------------------------------');

            END IF;
          ELSIF l_context_type = 'PRICING_ATTRIBUTE' OR l_context_type = 'PRODUCT' THEN

            l_price_count := l_price_count + 1;

            Add_to_Contexts_Results_Table(x_price_contexts_result_tbl,l_price_count,l_context_name,l_attribute_name,l_attribute_mvalue(l_index));

            IF l_debug = Fnd_Api.G_TRUE THEN
            Oe_Debug_Pub.ADD('Context(' || l_price_count || '): ' || x_price_contexts_result_tbl(l_price_count).context_name);
            Oe_Debug_Pub.ADD('SRC Type(' || l_price_count || '): ' || l_src_type);
            Oe_Debug_Pub.ADD('SRC Value(' || l_price_count || '): ' || l_attribute_value);
            Oe_Debug_Pub.ADD('Attribute Name(' || l_price_count || '): ' || x_price_contexts_result_tbl(l_price_count).attribute_name);
            Oe_Debug_Pub.ADD('Attribute Value(' || l_price_count || '): ' || x_price_contexts_result_tbl(l_price_count).attribute_value);
            Oe_Debug_Pub.ADD('------------------------------');

            END IF;
          ELSE
            IF l_debug = Fnd_Api.G_TRUE THEN
            Oe_Debug_Pub.ADD('Context type invalid');

            END IF;
          END IF;

        EXIT WHEN l_index = l_attribute_mvalue.LAST;

        END LOOP;

      END IF;

    ELSE
      IF l_debug = Fnd_Api.G_TRUE THEN
      Oe_Debug_Pub.ADD('No value was obtained in the mapping process of source type ' || l_src_type);

      END IF;
    END IF;

  END LOOP;

  IF g_dynamic_mapping_count = 0 THEN   -- 7323926
    -- IF l_count = 1 THEN     7323926
    g_dynamic_mapping_needed := 'N';
  END IF;

  CLOSE l_ctxts_new;

  RETURN;

END Map_Used_But_Not_Mapped_Attrs;


/* Bug#4509601 - Call to Put_Line is replaced with Print_Line to print
   Sourcing Rules Error Messages in Concurrent Program output file.
*/
PROCEDURE Check_All_Mapping
(        err_buff                OUT NOCOPY     VARCHAR2,
         retcode                 OUT NOCOPY     NUMBER,
         p_request_type_code     IN             VARCHAR2
)

IS

  TYPE l_cursor_type IS REF CURSOR;

  l_attribute_value    VARCHAR2(240);
  l_attribute_mvalue   Qp_Attr_Mapping_Pub.t_MultiRecord;
  l_context_name       qp_prc_contexts_b.prc_context_code%TYPE;
  l_attribute_name     qp_segments_b.segment_code%TYPE;
  l_attribute_map      qp_segments_b.segment_mapping_column%TYPE;
  l_src_type           qp_attribute_sourcing.user_sourcing_type%TYPE;
  l_pricing_type       qp_attribute_sourcing.attribute_sourcing_level%TYPE;
  l_value_string       qp_attribute_sourcing.user_value_string%TYPE;
  l_request_type       qp_attribute_sourcing.request_type_code%TYPE;
  l_pte_name           qp_pte_request_types_b.pte_code%TYPE;
  l_context_type       qp_prc_contexts_b.prc_context_type%TYPE;
  l_successful         BOOLEAN := TRUE;
  l_err_count          BINARY_INTEGER := 0;

  l_cursor l_cursor_type;

BEGIN
  IF Qp_Code_Control.CODE_RELEASE_LEVEL <= 110508 THEN
    Print_Line('This concurrent program is reserved for future use.');
  ELSE
    IF p_request_type_code IS NULL THEN
      OPEN l_cursor FOR
        SELECT qpseg.segment_mapping_column,
          qpsour.user_sourcing_type src_type,
          qpsour.user_value_string value_string,
          qpcon.prc_context_code context_code,
          qpsour.attribute_sourcing_level,
          qpsour.request_type_code,
          qpreq.pte_code,
          qpcon.prc_context_type,
          qpseg.segment_code
        FROM
          qp_segments_b qpseg,
          qp_attribute_sourcing qpsour,
          qp_prc_contexts_b qpcon,
          qp_pte_request_types_b qpreq,
          qp_pte_segments qppseg
        WHERE
          qpsour.segment_id = qpseg.segment_id
          AND qppseg.user_sourcing_method = 'ATTRIBUTE MAPPING'
          AND qpseg.prc_context_id = qpcon.prc_context_id
          AND qpreq.request_type_code = qpsour.request_type_code
          AND qppseg.pte_code = qpreq.pte_code
          AND qppseg.segment_id = qpsour.segment_id
          AND qppseg.sourcing_enabled = 'Y'
          AND qpsour.enabled_flag='Y' -- Modified for Bug no 5559174 by rassharm
          AND qpcon.prc_context_type IN ('PRICING_ATTRIBUTE', 'PRODUCT','QUALIFIER');
    ELSE
      OPEN l_cursor FOR
        SELECT qpseg.segment_mapping_column,
          qpsour.user_sourcing_type src_type,
          qpsour.user_value_string value_string,
          qpcon.prc_context_code context_code,
          qpsour.attribute_sourcing_level,
          qpsour.request_type_code,
          qpreq.pte_code,
          qpcon.prc_context_type,
          qpseg.segment_code

        FROM
          qp_segments_b qpseg,
          qp_attribute_sourcing qpsour,
          qp_prc_contexts_b qpcon,
          qp_pte_request_types_b qpreq,
          qp_pte_segments qppseg
        WHERE
          qpsour.segment_id = qpseg.segment_id
          AND qppseg.user_sourcing_method = 'ATTRIBUTE MAPPING'
          AND qpsour.request_type_code = p_request_type_code
          AND qpseg.prc_context_id = qpcon.prc_context_id
          AND qpreq.request_type_code = qpsour.request_type_code
          AND qppseg.pte_code = qpreq.pte_code
          AND qppseg.segment_id = qpsour.segment_id
          AND qppseg.sourcing_enabled = 'Y'
          AND qpsour.enabled_flag='Y' -- Modified for Bug no 5559174 by rassharm
          AND qpcon.prc_context_type IN ('PRICING_ATTRIBUTE', 'PRODUCT','QUALIFIER');
    END IF;

    LOOP

      FETCH l_cursor INTO
        l_attribute_map,
        l_src_type,
        l_value_string,
        l_context_name,
        l_pricing_type,
        l_request_type,
        l_pte_name,
        l_context_type,
        l_attribute_name;

      EXIT WHEN l_cursor%NOTFOUND;

      l_successful := TRUE;

      IF l_src_type = 'API' THEN
        l_attribute_value := Get_API_Value(l_value_string, l_successful);

      ELSIF l_src_type = 'API_MULTIREC' THEN
        BEGIN
          l_attribute_mvalue := Get_API_MultiValue(l_value_string, l_successful);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

      ELSIF l_src_type = 'PROFILE_OPTION' THEN
        l_attribute_value := Get_Profile_Option_Value(l_value_string, l_successful);

      ELSIF l_src_type = 'SYSTEM' THEN
        l_attribute_value := Get_System_Variable(l_value_string, l_successful);

      ELSIF l_src_type = 'CONSTANT' THEN
        l_attribute_value := l_value_string;

      ELSE
        IF l_debug = Fnd_Api.G_TRUE THEN
        Oe_Debug_Pub.ADD('Invalid source type');

        END IF;
      END IF;

      IF l_successful = FALSE THEN

        IF l_err_count = 0 THEN
          Print_Line('ATTRIBUTE MAPPING RULES ERRORS FOUND');
          Print_Line('------------------------------------------------------------');
          Print_Line('');
        END IF;

        Print_Line('PTE:           ' || l_pte_name);
        Print_Line('Context Type:  ' || l_context_type);
        Print_Line('Context:       ' || l_context_name);
        Print_Line('Attribute:     ' || l_attribute_name || ' (' || l_attribute_map || ')');
        Print_Line('Request Type:  ' || l_request_type);
        Print_Line('Level:         ' || l_pricing_type);
        Print_Line('Sourcing Rule: ' || l_value_string);
        Print_Line('Error Message: ' || g_err_mesg);
        Print_Line('');

        l_err_count := l_err_count + 1;
      END IF;

    END LOOP;
    CLOSE l_cursor;

    IF l_err_count = 0 THEN
      Print_Line('NO ATTRIBUTE MAPPING RULES ERROR(S) FOUND');
      retcode := 0;
    ELSE
      Print_Line('------------------------------------------------------------');
      Print_Line(l_err_count || ' ATTRIBUTE MAPPING RULES ERROR(S) FOUND');
      retcode := 1;
    END IF;

  END IF;

  RETURN;

  EXCEPTION
    WHEN OTHERS THEN
      Print_Line('*** ERROR IN CHECK MAPPING RULES CONCURRENT PROGRAM ***');
      Print_Line(SQLERRM);
      Print_Line('*******************************************************');
      retcode := 2;
      err_buff := SQLERRM;

END Check_All_Mapping;


END Qp_Attr_Mapping_Pub;

/
