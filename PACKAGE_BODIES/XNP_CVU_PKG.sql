--------------------------------------------------------
--  DDL for Package Body XNP_CVU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_CVU_PKG" AS
/* $Header: XNPCVUB.pls 120.2 2006/02/13 07:44:03 dputhiye ship $ */



g_category_no_error BOOLEAN; -- Used in StartCategory, EndCategory, EndOfTables

	FUNCTION GetNumErrMsg(v_msg_name IN VARCHAR2,
                    v_token_1 IN VARCHAR2 DEFAULT NULL,
                    v_value_1 IN VARCHAR2 DEFAULT NULL,
                    v_token_2 IN VARCHAR2 DEFAULT NULL,
                    v_value_2 IN VARCHAR2 DEFAULT NULL,
                    v_token_3 IN VARCHAR2 DEFAULT NULL,
                    v_value_3 IN VARCHAR2 DEFAULT NULL,
                    v_token_4 IN VARCHAR2 DEFAULT NULL,
                    v_value_4 IN VARCHAR2 DEFAULT NULL)
	RETURN VARCHAR2 IS
   		l_msg_name VARCHAR2(1996) := NULL;
	BEGIN
		l_msg_name := GetMsgTxt (v_msg_name,
                    v_token_1,
                    v_value_1,
                    v_token_2,
                    v_value_2,
                    v_token_3,
                    v_value_3,
                    v_token_4,
                    v_value_4);

        l_msg_name := fnd_message.get_number('XNP',v_msg_name) || ':'|| l_msg_name;
        return l_msg_name;

	EXCEPTION
      WHEN OTHERS THEN
			fnd_message.set_name('XNP','XNP_CVU_PROGRAM_ERROR');
			fnd_message.set_token('ERROR_CODE',to_char(SQLCODE));
			fnd_message.set_token('ERROR_MESSAGE',SQLERRM);
			htp.p(htf.bodyOpen);
			htp.p(gc_error_display||' : '||fnd_message.get);
			htp.p(htf.br);
			htp.p(htf.bodyClose);
	END GetNumErrMsg;


-- GetMsgTxt: Using msg_name and msg_tokens, form the message
--  v_msg_name: Message Name
--  v_token_n: Token to be substituted

   FUNCTION GetMsgTxt (v_msg_name IN VARCHAR2,
                    v_token_1 IN VARCHAR2 DEFAULT NULL,
                    v_value_1 IN VARCHAR2 DEFAULT NULL,
                    v_token_2 IN VARCHAR2 DEFAULT NULL,
                    v_value_2 IN VARCHAR2 DEFAULT NULL,
                    v_token_3 IN VARCHAR2 DEFAULT NULL,
                    v_value_3 IN VARCHAR2 DEFAULT NULL,
                    v_token_4 IN VARCHAR2 DEFAULT NULL,
                    v_value_4 IN VARCHAR2 DEFAULT NULL)
   RETURN VARCHAR2
   IS
   l_msg_name VARCHAR2(1996) := NULL;
   BEGIN
        fnd_message.set_name('XNP',substr(v_msg_name, 1, 30));

        if (v_token_1 IS NOT NULL) then
           fnd_message.set_token(v_token_1, v_value_1);
        end if;
        if (v_token_2 IS NOT NULL) then
           fnd_message.set_token(v_token_2, v_value_2);
        end if;
        if (v_token_3 IS NOT NULL) then
           fnd_message.set_token(v_token_3, v_value_3);
        end if;
        if (v_token_4 IS NOT NULL) then
           fnd_message.set_token(v_token_4, v_value_4);
        end if;

        l_msg_name := fnd_message.get;
        return l_msg_name;

   EXCEPTION
      WHEN OTHERS THEN
          fnd_message.set_name('XNP','XNP_CVU_PROGRAM_ERROR');
	  fnd_message.set_token('ERROR_CODE',to_char(SQLCODE));
	  fnd_message.set_token('ERROR_MESSAGE',SQLERRM);
	  htp.p(htf.bodyOpen);
	  htp.p(gc_error_display||' : '||fnd_message.get);
          htp.p(htf.br);
          htp.p(htf.bodyClose);
   END GetMsgTxt;

-- Print: Print the message based on the paramters passed
--  p_text: Text to be printed
--  p_text_indicator: 'OK','ERROR','WARNING'
--  p_text_type: gc_RECORDS, gc_HEADER, gc_MESSAGE, gc_FOOTER, gc_CONTEXT, gc_SUB_CONTEXT

	PROCEDURE Print(
      p_text IN VARCHAR2,
      p_text_indicator IN VARCHAR2 DEFAULT gc_OK,
      p_text_type IN VARCHAR2 DEFAULT gc_RECORDS)
    IS
	BEGIN

        IF p_text_type = gc_HEADER THEN
                htp.p(htf.nl);
                htp.p(htf.nl);
				htp.fontOpen(ccolor=>'blue', csize=>5);
                htp.p(htf.italic(p_text)) ;
				htp.fontClose;
                htp.p(htf.nl);
                htp.p(htf.nl);
        ELSIF p_text_type = gc_CONTEXT OR p_text_type = gc_MESSAGE THEN
				htp.fontOpen(ccolor=>'gray', csize=>3);
                htp.p(htf.para);
                htp.p(htf.strong(p_text)) ;
				htp.fontClose;
                htp.p(htf.line);
        ELSIF p_text_type = gc_SUB_CONTEXT THEN
				htp.fontOpen(ccolor=>'gray', csize=>3);
                htp.p(htf.strong(p_text)) ;
				htp.fontClose;
		ELSIF p_text_type = gc_RECORDS THEN
                	htp.p(htf.strong(p_text)) ;
        END IF;


   EXCEPTION
      WHEN OTHERS THEN
          -- log error;
		fnd_message.set_name('XNP','XNP_CVU_PROGRAM_ERROR');
		fnd_message.set_token('ERROR_CODE',to_char(SQLCODE));
		fnd_message.set_token('ERROR_MESSAGE',SQLERRM);
		htp.p(htf.bodyOpen);
		htp.p(gc_error_display||' : '||fnd_message.get);
		htp.p(htf.br);
		htp.p(htf.bodyClose);
   END Print;

   FUNCTION GetGeoCode(id IN NUMBER)
    RETURN VARCHAR2
   IS
    l_code VARCHAR2(40) := NULL;
   BEGIN
     SELECT code
     INTO   l_code
     FROM   xnp_geo_areas_b
     WHERE  geo_area_id = id;
     RETURN l_code;
   END;


   FUNCTION GetFeName(id IN NUMBER)
    RETURN VARCHAR2
   IS
    l_FeName VARCHAR2(40) := NULL;
    l_fe_type VARCHAR2(40) := NULL;
    l_fe_type_id NUMBER := NULL;
    l_fe_sw_generic VARCHAR2(40) := NULL;
    l_adapter_type VARCHAR2(40) := NULL;

   BEGIN
     xdp_engine.get_fe_configinfo
	(id
	,l_FeName
	,l_fe_type_id
	,l_fe_type
	,l_fe_sw_generic
	,l_adapter_type
	);
     RETURN l_FeName;
   END;

-- HandleError
--

    PROCEDURE HandleError(p_custom_message IN VARCHAR2,
                        p_sqlcode IN NUMBER,
                        p_sqlerrm IN VARCHAR2)
    IS
    BEGIN

        Print(p_custom_message || ' ' ||p_sqlerrm, gc_OK, gc_message);

    EXCEPTION
      WHEN OTHERS THEN
          htp.p('HandleError'|| sqlerrm);
    END HandleError;



	FUNCTION ColorCode(
				p_text VARCHAR2,
                p_indicator VARCHAR2,
				p_type VARCHAR2) RETURN VARCHAR2
	IS
		v_text VARCHAR2(200);
	BEGIN

		v_text := p_text;

		IF p_type = gc_HEADING THEN
			v_text := p_text;
		ELSIF p_type = gc_DETAILS THEN
			IF p_indicator = gc_ERROR THEN
				v_text := htf.fontOpen(ccolor=>'red')||p_text||htf.fontClose;
			ELSIF p_indicator = gc_WARNING THEN
				v_text := htf.fontOpen(ccolor=>'amber')||p_text||htf.fontClose;
			ELSE
				v_text := p_text;
			END IF;
		ELSE
			v_text := p_text;

		END IF;

		return v_text;

    EXCEPTION
      WHEN OTHERS THEN
			return v_text;
	END ColorCode;




    PROCEDURE  PrintReportDetails(
                p_type VARCHAR2,
				p_indicator VARCHAR2,
                p_one VARCHAR2,
                p_two VARCHAR2 Default NULL,
                p_three VARCHAR2 Default NULL,
                p_four VARCHAR2 Default NULL,
                p_five VARCHAR2 Default NULL)
    IS
        v_text VARCHAR2(1000);
        v_one_len NUMBER := 50;
        v_two_len NUMBER := 50;
        v_three_len NUMBER := 50;
        v_four_len NUMBER := 50;
        v_five_len NUMBER := 50;

		v_delim VARCHAR2(40);

    BEGIN


    IF p_type = gc_HEADING THEN

		v_delim := gc_TH;

	    IF  p_five IS NOT NULL THEN
			v_text :=
				ColorCode(lpad(p_one, v_one_len), p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_two, v_two_len),p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_three, v_three_len),p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_four, v_four_len),p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_five, v_five_len),p_indicator, p_type);
		ELSIF p_four IS NOT NULL THEN
			v_text :=
				ColorCode(lpad(p_one, v_one_len), p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_two, v_two_len),p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_three, v_three_len),p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_four, v_four_len),p_indicator, p_type);
	    ELSIF p_three IS NOT NULL THEN
			v_text :=
				ColorCode(lpad(p_one, v_one_len), p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_two, v_two_len),p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_three, v_three_len),p_indicator, p_type);
	    ELSIF p_two IS NOT NULL THEN
			v_text :=
				ColorCode(lpad(p_one, v_one_len), p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_two, v_two_len),p_indicator, p_type);
	    ELSE
			v_text :=
				ColorCode(lpad(p_one, v_one_len), p_indicator, p_type);
		END IF;

		v_text := gc_TRTH_open ||v_text || gc_TRTH_close;
		Print(gc_TABLE_open, gc_OK, gc_RECORDS);
		Print(v_text, p_indicator, gc_RECORDS);

    ELSIF p_type = gc_DETAILS THEN
		v_delim  := gc_TD;

	    IF  p_five IS NOT NULL THEN
			v_text :=
				ColorCode(lpad(p_one, v_one_len), p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_two, v_two_len),p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_three, v_three_len),p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_four, v_four_len),p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_five, v_five_len),p_indicator, p_type);
		ELSIF p_four IS NOT NULL THEN
			v_text :=
				ColorCode(lpad(p_one, v_one_len), p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_two, v_two_len),p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_three, v_three_len),p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_four, v_four_len),p_indicator, p_type);
	    ELSIF p_three IS NOT NULL THEN
			v_text :=
				ColorCode(lpad(p_one, v_one_len), p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_two, v_two_len),p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_three, v_three_len),p_indicator, p_type);
	    ELSIF p_two IS NOT NULL THEN
			v_text :=
				ColorCode(lpad(p_one, v_one_len), p_indicator, p_type)
				||v_delim ||
				ColorCode(lpad(p_two, v_two_len),p_indicator, p_type);
	    ELSE
			v_text :=
				ColorCode(lpad(p_one, v_one_len), p_indicator, p_type);
		END IF;

       	v_text := gc_TRTD_open || v_text || gc_TRTD_close;
		Print(v_text, p_indicator, gc_RECORDS);

    ELSIF p_type = gc_SUB_CONTEXT THEN
       Print(v_text, gc_OK, gc_SUB_CONTEXT);
    ELSE
       Print(v_text, gc_OK, gc_CONTEXT);
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
          htp.p ('PrintReportDetails' || sqlerrm);
    END PrintReportDetails;

	-- Table is opened in the heading printing.
	-- heading is printed only for the first time (in most cases)
	-- After that first_time flag is set to FALSE
	-- so it is sufficient to pass the  NOT(p_first_time) flag to this.

	PROCEDURE EndOfTable(p_table_open BOOLEAN)
	IS
	BEGIN

		IF p_table_open THEN
			IF g_display_type = gc_HTML THEN
				-- Close Table Opened in Header
				Print(gc_TABLE_close, gc_OK, gc_RECORDS);
			END IF;
			g_category_no_error := FALSE; -- Used in EndCategory function
		END IF;


    EXCEPTION
      WHEN OTHERS THEN
          htp.p ('EndOfTable' || sqlerrm);
    END  EndOfTable;

   -- Message Names:
   --   INITIAL_STATUS_OF_SV
   --       One and Only one Subscription Version Status Type among the
   --       Active status types should be "Initial Status of
   --       subscription version

    PROCEDURE INITIAL_STATUS_OF_SV IS
        v_found BOOLEAN := FALSE;
        v_text VARCHAR2(1000);
        v_default_porting_status varchar2(150) := null;
        v_cnt   NUMBER := 0;
        v_invalid_status number := 0;

    BEGIN
        FND_PROFILE.GET(NAME => 'DEFAULT_PORTING_STATUS',
						VAL => v_default_porting_status);

        SELECT	1
		INTO	v_invalid_status
		FROM	dual
		WHERE	EXISTS
               (SELECT	'X'
				FROM	xnp_sv_status_types_b
				WHERE	status_type_code = v_default_porting_status
				AND		active_flag = 'Y');

        EXCEPTION when no_data_found then
            v_text := GetNumErrMsg('XNP_CVU_INITIAL_STATUS_OF_SV');
            Print(v_text,gc_ERROR, gc_MESSAGE);
        WHEN OTHERS THEN
            HandleError('INITIAL_STATUS_OF_SV', SQLCODE, SQLERRM);
    END INITIAL_STATUS_OF_SV;

   -- Message Names:
   --   XNP_CVU_LOCAL_SP_NAME
   --    The local sp's name must be not null and must be a
   --      valid service provider name
   --

    PROCEDURE LOCAL_SP_NAME IS
        v_found BOOLEAN := FALSE;
        v_text VARCHAR2(1000);
        v_local_sp_name varchar2(150) := null;
        v_invalid_sp_name number := 0;

    BEGIN
        FND_PROFILE.GET(NAME => 'SP_NAME',
						VAL => v_local_sp_name);

        SELECT 1
          INTO v_invalid_sp_name
          FROM dual
         WHERE EXISTS
               (SELECT 'X'
                  FROM xnp_service_providers
                 WHERE code = v_local_sp_name
		   AND active_flag = 'Y');

        EXCEPTION when no_data_found then
            v_text := GetNumErrMsg('XNP_CVU_LOCAL_SP_NAME');
            Print(v_text,gc_ERROR, gc_MESSAGE);
        WHEN OTHERS THEN
            HandleError('LOCAL_SP_NAME', SQLCODE, SQLERRM);
    END LOCAL_SP_NAME;


    -- Message Names:
    --   XNP_CVU_PHASE_IND_NO_STAT_TYPE
    --  Each Phase Indicator should have at least one
	--  Active Status Type Code associated with it

    PROCEDURE PHASE_IND_NO_STAT_TYPE IS

    v_text VARCHAR2(1000);

    CURSOR c_pi IS
        SELECT  pi , count(*) cnt,
           decode (pi,
                    'INQUIRY', decode (count(*), 0, gc_WARNING,gc_OK),
                    decode(count(*), 0, gc_ERROR,gc_OK)) result_type
        FROM
            (SELECT     flv.lookup_code pi, sst.status_type_code stc
            FROM        xnp_sv_status_types_b sst, fnd_lookup_values flv
            WHERE       flv.lookup_code = sst.phase_indicator (+)
            AND         flv.lookup_type = 'XNP_PHASE_INDICATOR'
            AND         flv.enabled_flag = 'Y'
            AND         sst.active_flag = 'Y')
        GROUP BY pi;

        v_first_time BOOLEAN := TRUE;
    BEGIN
        FOR pi_rec in c_pi
        LOOP
            IF pi_rec.result_type = gc_ERROR THEN
              IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_PHASE_IND_NO_STAT_TYPE');
                Print(v_text,gc_ERROR,gc_CONTEXT);

                PrintReportDetails(gc_HEADING,gc_ERROR, 'PHASE_INDICATOR','COUNT', 'RESULT');

                v_first_time := FALSE;
              END IF;
              PrintReportDetails(gc_DETAILS, pi_rec.result_type,
								pi_rec.pi, pi_rec.cnt, pi_rec.result_type);
              Print(v_text, pi_rec.result_type, gc_RECORDS);
            END IF;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            HandleError('PHASE_IND_NO_STAT_TYPE', SQLCODE, SQLERRM);
    END PHASE_IND_NO_STAT_TYPE;

   -- Mesage Name:
   --   XNP_CVU_SINGLE_GEO_TREE
   --       There can be only one Geographic tree and except for "WORLD"
   --       no other node can have parent node to be null

    PROCEDURE SINGLE_GEO_TREE IS

    -- CHECK: Need to look at performance issue in big trees

    -- Bug fix 1647105.

    CURSOR   c_bad_nodes IS
        SELECT 	gho.child_geo_area_id child,
                gho.parent_geo_area_id parent
        FROM 	xnp_geo_hierarchy gho
        WHERE 	NOT EXISTS
            (SELECT 	'X'
            FROM		xnp_geo_hierarchy ghi
            WHERE       ghi.child_geo_area_id = gho.child_geo_area_id
            AND         ghi.parent_geo_area_id = gho.parent_geo_area_id
            -- START WITH  parent_geo_area_id = 0
            START WITH  parent_geo_area_id = (select geo_area_id from xnp_geo_areas_b
					where geo_area_type_code = 'REGION' and
						code = 'WORLD')
            CONNECT BY  PRIOR	child_geo_area_id  = parent_geo_area_id);

        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;

    BEGIN
        FOR bad_nodes_rec IN c_bad_nodes
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_SINGLE_GEO_TREE');
                Print(v_text,gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_ERROR, 'PARENT','CHILD');

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_ERROR,
				GetGeoCode(bad_nodes_rec.parent),
				GetGeoCode(bad_nodes_rec.child));
        END LOOP;

		EndOfTable(NOT v_first_time);

        EXCEPTION
        WHEN OTHERS THEN
            HandleError('SINGLE_GEO_TREE', SQLCODE, SQLERRM);
    END SINGLE_GEO_TREE;



    -- Message Name:
    --   XNP_CVU_FA_SHOULD_HAVE_FP
    --          FA should have FP configured for it
    --   XNP_CVU_FA_SHOULD_HAVE_FE
    --          If FA has a valid configuration,
    --          it should have a valid FEs defind for it

    PROCEDURE FULFILL_ACTIONS
    IS
        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;

        CURSOR  c_no_fp IS
            SELECT 	fulfillment_action_id id, fulfillment_action name
            FROM 	xdp_fulfill_actions fa
            WHERE 	NOT EXISTS
            		(SELECT   1
            		FROM      xdp_fa_fulfillment_proc fap
            		WHERE     fap.fulfillment_action_id = fa.fulfillment_action_id);

         CURSOR  c_no_fe IS
            SELECT 	fulfillment_action_id id, fulfillment_action name
            FROM 	xdp_fulfill_actions fa
            WHERE 	EXISTS
            		(SELECT   1
            		FROM      xdp_fa_fulfillment_proc fap
            		WHERE     fap.fulfillment_action_id = fa.fulfillment_action_id)

            AND		NOT EXISTS
            		(SELECT   1
            		FROM      xdp_fa_fulfillment_proc fap ,
                                  xdp_fes fes,
                                  xdp_fe_sw_gen_lookup fgl
            		WHERE     fap.fulfillment_action_id
                                  = fa.fulfillment_action_id
                        AND       fap.fe_sw_gen_lookup_id
                                  = fgl.fe_sw_gen_lookup_id
                        AND	  fgl.fetype_id = fes.fetype_id
                        AND	  SYSDATE BETWEEN fes.valid_date
                                          AND     nvl(fes.invalid_date, gc_max_date));

    BEGIN
        FOR rec IN c_no_fp
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_FA_SHOULD_HAVE_FP');
                Print(v_text,gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_ERROR, gc_ID, gc_NAME);

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_ERROR, rec.id, rec.name);
        END LOOP;

		EndOfTable(NOT v_first_time);


        v_text := NULL;
        v_first_time := TRUE;

        FOR rec IN c_no_fe
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_FA_SHOULD_HAVE_FE');
                Print(v_text,gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_ERROR, gc_ID, gc_NAME);

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_ERROR, rec.id, rec.name);

        END LOOP;

		EndOfTable(NOT v_first_time);


        EXCEPTION
            WHEN OTHERS THEN
                HandleError('FULFILL_ACTIONS', SQLCODE, SQLERRM);
    END FULFILL_ACTIONS;


    --  Message Names:
    --   XNP_CVU_INVALID_FE
    --          If valid_date is null or invalid_date < sysdate
    --   XNP_CVU_FE_DATE_WINDOW
    --          Generic Configuration date window must lie within the corresponding
    --          Fulfillment Elements date window.

    PROCEDURE FULFILL_ELEMENT_VALIDITY
    IS
        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;

        CURSOR  c_invalid_fe IS
        SELECT	fe_id id, fulfillment_element_name name,
				to_char(invalid_date, gc_DATE_FORMAT) valid_date,
                DECODE(invalid_date, null, gc_NULL,
					to_char(invalid_date, gc_DATE_FORMAT)) invalid_date
        FROM	xdp_fes
        WHERE	invalid_date < SYSDATE;

        CURSOR  c_date_window IS
        SELECT	fe.fe_id id, fulfillment_element_name name,
				to_char(valid_date, gc_DATE_FORMAT) valid_date,
                DECODE(invalid_date, null, gc_NULL,
					to_char(invalid_date, gc_DATE_FORMAT)) invalid_date
        FROM	xdp_fes fe, xdp_fe_generic_config fgc
        WHERE	fe.fe_id = fgc.fe_id
        AND NOT
                (fgc.start_date BETWEEN
                fe.valid_date and nvl(fe.invalid_date, gc_max_date)
        AND
                nvl(fgc.end_date, gc_max_date) BETWEEN
                fe.valid_date and nvl(fe.invalid_date, gc_max_date));

    BEGIN
        FOR rec IN c_invalid_fe
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_INVALID_FE');
                Print(v_text,gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_ERROR, gc_NAME,
                                gc_VALID_DATE, gc_INVALID_DATE);
                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_ERROR, rec.name,
							rec.valid_date, rec.invalid_date);

        END LOOP;

		EndOfTable(NOT v_first_time);

        v_first_time := TRUE;

        FOR rec IN c_date_window
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_FE_DATE_WINDOW');
                Print(v_text,gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_ERROR, gc_NAME,
                                gc_VALID_DATE, gc_INVALID_DATE);
                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_ERROR, rec.name,
							rec.valid_date, rec.invalid_date);

        END LOOP;
		EndOfTable(NOT v_first_time);

    EXCEPTION
        WHEN OTHERS THEN
        HandleError('FULFILL_ELEMENT_VALIDITY', SQLCODE, SQLERRM);
    END FULFILL_ELEMENT_VALIDITY;


    -- Message Names
    --   XNP_CVU_FE_NO_GENERIC_CONFIG
    --          Every Fulfillment Element  should have a  Valid Generic Configuration
    --   XNP_CVU_FE_NO_ADAPTER
    --          FE should have adapters defined for it.
    --   XNP_CVU_FETYPE_NO_SW_GEN
    --      Every Fulfillment Element Type should have a  Valid  SW Generic Configuration

   PROCEDURE FULFILL_ELEMENT_REFERENCES
   IS
        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;

        CURSOR c_no_gen_config IS
            SELECT	fe.fe_id id , fe.fulfillment_element_name name
            FROM    xdp_fes fe
            WHERE	NOT EXISTS
                (SELECT 1
                FROM		xdp_fe_generic_config fgc
                WHERE 	fe.fe_id = fgc.fe_id
                AND		SYSDATE BETWEEN fgc.start_date
                AND		nvl(fgc.end_date, gc_max_date)
                );

        CURSOR c_no_adapter  IS
            SELECT	fe.fe_id id, fe.fulfillment_element_name name
            FROM	xdp_fes fe
            WHERE	NOT EXISTS
                (SELECT 1
                FROM	xdp_adapter_reg ar
                WHERE 	fe.fe_id = ar.fe_id);

        CURSOR c_no_sw_gen_config IS
            SELECT	fet.fetype_id id, fet.fulfillment_element_type name
            FROM	xdp_fe_types fet
            WHERE	NOT EXISTS
                (SELECT 1
                FROM	xdp_fe_sw_gen_lookup sgl
                WHERE 	fet.fetype_id = sgl.fetype_id
                );

    BEGIN
        FOR rec IN c_no_gen_config
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_FE_NO_GENERIC_CONFIG');
                Print(v_text,gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_ERROR, gc_ID, gc_NAME);

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_ERROR, rec.id, rec.name);

        END LOOP;

		EndOfTable(NOT v_first_time);

        v_first_time := TRUE;
        FOR rec IN c_no_adapter
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_FE_NO_ADAPTER');
                Print(v_text,gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_ERROR, gc_ID, gc_NAME);

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_ERROR, rec.id, rec.name);

        END LOOP;

		EndOfTable(NOT v_first_time);

        v_first_time := TRUE;
        FOR rec IN c_no_sw_gen_config
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_FETYPE_NO_SW_GEN');
                Print(v_text,gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_ERROR, gc_ID, gc_NAME);

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_ERROR, rec.id, rec.name);

        END LOOP;

		EndOfTable(NOT v_first_time);

    EXCEPTION
         WHEN OTHERS THEN
            HandleError('FULFILL_ELEMENT_REFERENCES', SQLCODE, SQLERRM);
    END FULFILL_ELEMENT_REFERENCES;



   -- Message Names:
   --       XNP_CVU_NEW_ADAPTER_NO_PORC
   --           If ADAPTER_TYPE is  "FILE", "JSCRIPT" or  "INTERACTIVE"
   --           then there should be a procedure defined in SW_START_PROC and SW_END_PROC.

    PROCEDURE NEW_ADAPTER_TYPES
    IS
        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;

        CURSOR  c_no_proc IS
            SELECT	fgc.fe_id,
                        nvl(fgc.sw_start_proc, gc_NULL) sw_start_proc,
                        nvl(fgc.sw_exit_proc, gc_NULL) sw_exit_proc
            FROM	xdp_fe_generic_config fgc
            WHERE	EXISTS
                        (SELECT 1
                        FROM    xdp_fes fes
                        WHERE   fes.fe_id = fgc.fe_id
                        AND     fetype_id IN (SELECT fetype_id
                                             FROM    xdp_fe_types
                                             WHERE   fulfillment_element_type
                                             IN      (gc_FILE
                                                     , gc_JSCRIPT
													 , gc_INTERACTIVE)))

            AND         (fgc.sw_start_proc IS NULL
                        OR
                        fgc.sw_exit_proc IS NULL);

    BEGIN
        FOR rec IN c_no_proc
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_NEW_ADAPTER_NO_PORC');
                Print(v_text,gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_ERROR, 'SW_START_PROC', 'SW_END_PROC');

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_ERROR, rec.sw_start_proc, rec.sw_exit_proc);

        END LOOP;

		EndOfTable(NOT v_first_time);

    EXCEPTION
            WHEN OTHERS THEN
                HandleError('NEW_ADAPTER_TYPES', SQLCODE, SQLERRM);
    END NEW_ADAPTER_TYPES;

    -- Message Names:
    --  SP_NO_ADAPTER:
    --      Service Provider should have valid adapter associated with it.

    PROCEDURE SERVICE_PROVIDERS IS

    v_text VARCHAR2(1000);
    v_first_time BOOLEAN := TRUE;

    CURSOR c_sp IS
        SELECT  sp_id, code, sp_type, name
        FROM    xnp_service_providers sp
        WHERE   NOT EXISTS
            (SELECT 1
            FROM    xnp_sp_adapters spa
            WHERE   sp.sp_id = spa.sp_id);
    BEGIN
        FOR rec IN c_sp
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_SP_NO_ADAPTER');
                Print(v_text,gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_ERROR, 'CODE', 'SP_TYPE', 'NAME');

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_ERROR, rec.code, rec.sp_type, rec.name);

        END LOOP;

		EndOfTable(NOT v_first_time);

    EXCEPTION
            WHEN OTHERS THEN
                HandleError('SERVICE_PROVIDERS', SQLCODE, SQLERRM);
    END SERVICE_PROVIDERS;


    -- Message Names:
    --   XNP_CVU_NUM_RANGE_NO_GEO_ID
    --       If the Geo Area Indicator is GEO then Number range
    --       should have associated Geographic Area
    --   XNP_CVU_NUM_RANGE_GEO
    --       If the Geo Area Indicator is NOT GEO then Number range
    --       should NOT have Geographic Area

    PROCEDURE NUM_RANGE_GEO_AREA
    IS
        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;

        CURSOR c_geo_num_range IS
        SELECT	number_range_id, starting_number, ending_number
        FROM	xnp_number_ranges
        WHERE	geo_indicator = gc_GEO
        AND		geo_area_id IS NULL;

        CURSOR c_nogeo_num_range IS
        SELECT	number_range_id, starting_number,ending_number
        FROM	xnp_number_ranges
        WHERE	geo_indicator <> gc_GEO
        AND		geo_area_id IS NOT NULL;

    BEGIN
        v_first_time := TRUE;
        FOR rec IN c_geo_num_range
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_NUM_RANGE_NO_GEO_ID');
                Print(v_text,gc_WARNING, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_WARNING,
							'NUMBER_RANGE_ID', 'STARTING_NUM', 'ENDING_NUM');

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_WARNING,
						rec.number_range_id, rec.starting_number, rec.ending_number);

        END LOOP;

		EndOfTable(NOT v_first_time);

        v_first_time := TRUE;
        FOR rec IN c_nogeo_num_range
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_NUM_RANGE_GEO');
                Print(v_text,gc_WARNING, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_WARNING,
							'NUMBER_RANGE_ID', 'STARTING_NUM', 'ENDING_NUM');

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_WARNING,
						rec.number_range_id, rec.starting_number, rec.ending_number);

        END LOOP;

		EndOfTable(NOT v_first_time);

        EXCEPTION
            WHEN OTHERS THEN
                HandleError('NUM_RANGE_GEO_AREA', SQLCODE, SQLERRM);
    END NUM_RANGE_GEO_AREA;

    -- Message Names:
    --    XNP_CVU_INVALID_NUM_RANGES
    --        Number Range needs to be "Active" and currently Effective

    PROCEDURE INVALID_NUMBER_RANGES
    IS
        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;

        CURSOR c_num_range IS
        SELECT 	number_range_id, starting_number, ending_number,
				to_char(effective_date, gc_DATE_FORMAT) effective_date,
                nvl(active_flag, gc_NULL) active_flag
        FROM	xnp_number_ranges
        WHERE	effective_date > SYSDATE
        OR		nvl(active_flag,'N') <> 'Y';


    BEGIN
        FOR rec IN c_num_range
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_INVALID_NUM_RANGES');
                Print(v_text,gc_WARNING, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_WARNING,
							'NUMBER_RANGE_ID', 'STARTING_NUM', 'ENDING_NUM',
							'EFFECTIVE_DATE', 'ACTIVE_FLAG');

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_WARNING,
						rec.number_range_id, rec.starting_number, rec.ending_number,
						rec.effective_date, rec.active_flag);

        END LOOP;

		EndOfTable(NOT v_first_time);

        EXCEPTION
            WHEN OTHERS THEN
                HandleError('INVALID_NUMBER_RANGES', SQLCODE, SQLERRM);
    END INVALID_NUMBER_RANGES;

    -- Message Names:
    --      XNP_CVU_NOT_POOLED_NUM_RANGES
    --          If number range is not a pooled one, then Assigned Service provider and the
    --          Owning Service provider should be same
    --      XNP_CVU_POOLED_NUM_RANGES
    --          If it is a Pooled number range and Assigned Service provider should not be NULL

    PROCEDURE POOLED_NUMBER_RANGES
    IS
        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;

        CURSOR c_not_pooled_num_ranges IS
                SELECT 	number_range_id, starting_number, ending_number,
                        assigned_sp_id, owning_sp_id, pooled_flag
                FROM	xnp_number_ranges
                WHERE	pooled_flag = 'N'
                AND		assigned_sp_id <> owning_sp_id;

        CURSOR c_pooled_num_ranges IS
                SELECT 	number_range_id, starting_number, ending_number
                FROM	xnp_number_ranges
                WHERE	pooled_flag = 'Y'
                AND		assigned_sp_id IS NULL;

    BEGIN
        v_first_time := TRUE;
        FOR rec IN c_not_pooled_num_ranges
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_NOT_POOLED_NUM_RANGES');
                Print(v_text,gc_WARNING, gc_CONTEXT);
                PrintReportDetails(gc_HEADING, gc_WARNING,
							'NUMBER_RANGE_ID', 'STARTING_NUM', 'ENDING_NUM',
							'ASSIGNED_SP_ID', 'OWNING_SP_ID');

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_WARNING,
						rec.number_range_id, rec.starting_number, rec.ending_number,
						rec.assigned_sp_id, rec.owning_sp_id);

        END LOOP;

		EndOfTable(NOT v_first_time);

        v_first_time := TRUE;
        FOR rec IN c_pooled_num_ranges
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_POOLED_NUM_RANGES');
                Print(v_text,gc_WARNING, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_WARNING,
							'NUMBER_RANGE_ID', 'STARTING_NUM', 'ENDING_NUM');

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_WARNING,
						rec.number_range_id, rec.starting_number, rec.ending_number);

        END LOOP;

		EndOfTable(NOT v_first_time);

    EXCEPTION
        WHEN OTHERS THEN
           HandleError('POOLED_NUMBER_RANGES', SQLCODE, SQLERRM);
    END POOLED_NUMBER_RANGES;

    --  Message Names:
    --    NON_PORT_NUM_RANGES
    --        If the Number Range is "Non Ported" or "Non Portable" then indicate "WARNING".

    PROCEDURE NON_PORTED_PORTABLE_NUM_RANGES
    IS
        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;

        CURSOR  c_number_ranges IS
        SELECT	number_range_id,
                starting_number, ending_number, ported_indicator
        FROM	xnp_number_ranges
        WHERE	ported_indicator NOT IN ('NON_PORTED', 'NON_PORTABLE');

    BEGIN
        v_first_time  := TRUE;
        FOR rec IN c_number_ranges
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_NON_PORT_NUM_RANGES');
                Print(v_text,gc_WARNING, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_WARNING,
							'NUMBER_RANGE_ID', 'STARTING_NUM', 'ENDING_NUM',
							'PORTED_INDICATOR');

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_WARNING,
						rec.number_range_id, rec.starting_number, rec.ending_number,
						rec.ported_indicator);

        END LOOP;

		EndOfTable(NOT v_first_time);

    EXCEPTION
       WHEN OTHERS THEN
          HandleError('NON_PORTED_PORTABLE_NUM_RANGES', SQLCODE, SQLERRM);
    END NON_PORTED_PORTABLE_NUM_RANGES;


    -- Message Names:
    --   XNP_CVU_SERVED_FE_NP_FEATURE
    --       Served number ranges must have fulfillment element
    --       associated with it.

    PROCEDURE SERVED_NUMBER_RANGES
    IS
        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;


        CURSOR  c_served_num_ranges_err IS
        SELECT	snr.number_range_id, nr.starting_number, nr.ending_number
        FROM	xnp_served_num_ranges snr, xnp_number_ranges nr
        WHERE  NOT EXISTS
                (SELECT	'X'
                FROM	xdp_fes fes
                WHERE	fes.fe_id  = snr.fe_id
                AND		SYSDATE
                        BETWEEN fes.valid_date and NVL(fes.invalid_date,SYSDATE)
                )
        AND     nr.number_range_id = snr.number_range_id;
    BEGIN
        v_first_time := TRUE;
        FOR rec IN c_served_num_ranges_err
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_SERVED_FE_NP_FEATURE');
                Print(v_text,gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_ERROR, 'NUMBER_RANGE_ID','STARTING_NUMBER',
                            'ENDING_NUMBER');

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_ERROR,
						rec.number_range_id, rec.starting_number, rec.ending_number);

        END LOOP;

		EndOfTable(NOT v_first_time);

    EXCEPTION
       WHEN OTHERS THEN
          HandleError('SERVED_NUMBER_RANGES', SQLCODE, SQLERRM);
    END SERVED_NUMBER_RANGES;



    -- Message Name:
    --       XNP_CVU_ENABLE_NRC

    PROCEDURE ENABLE_NRC
    IS
        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;
        v_nrc_id NUMBER := NULL;
        v_error_code NUMBER := NULL;
        v_error_message VARCHAR2(1000) := NULL;

        CURSOR  c_number_ranges IS
        SELECT	number_range_id,
                starting_number, ending_number
        FROM	xnp_number_ranges;


    BEGIN
        v_first_time  := TRUE;
        FOR rec IN c_number_ranges
        LOOP

            xnp_core.get_nrc_id(rec.starting_number, rec.ending_number,
                                v_nrc_id, v_error_code, v_error_message);

			/* Bug Fix
            -- v_nrc_id = NULL => Error
            -- v_nrc_id = 0 => NRC not found

            IF v_nrc_id = 0 THEN
			*/
			-- v_error_code = 0 => NRC Flag NOT set or NRC Found
			-- v_error_code <> 0 => NRC not found

			IF v_error_code <> 0 THEN
                IF v_first_time THEN
                    v_text := GetNumErrMsg('XNP_CVU_ENABLE_NRC');
                    Print(v_text,gc_ERROR, gc_MESSAGE);

                	PrintReportDetails(gc_HEADING, gc_ERROR,
							'NUMBER_RANGE_ID','STARTING_NUMBER',
                            'ENDING_NUMBER');

	                v_first_time := FALSE;
				END IF;

				PrintReportDetails(gc_DETAILS,gc_ERROR,
						rec.number_range_id, rec.starting_number, rec.ending_number);

			END IF;

        END LOOP;
		EndOfTable(NOT v_first_time);

    EXCEPTION
       WHEN OTHERS THEN
          HandleError('ENABLE_NRC', SQLCODE, SQLERRM);
    END ENABLE_NRC;

    --  Message Names:
    --      XNP_CVU_INVALID_SERVICES
    --          If valid_date is null or invalid_date < sysdate then
    --          issue warninG.
    --          Removed after 11.5.6
    --      XNP_CVU_SERVICE_ACTIONS
    --          Service should have valid actions defined for it.
    --          Removed after 11.5.6
    --      XNP_CVU_DSERVICE_WI_MAP
    --          For dynamic Service Action WI Mapping procedure must be defined

    PROCEDURE SERVICE_VALIDATIONS
    IS
        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;
--
--  remove the following validations as part of integration with inventory
--  07/19/2001
--
/*
        CURSOR c_invalid_service_warn IS
        SELECT	service_id id , service_name name,
				to_char(valid_date, gc_DATE_FORMAT) valid_date,
                DECODE(invalid_date, NULL, gc_NULL,
					to_char(invalid_date, gc_DATE_FORMAT)) invalid_date
        FROM	xdp_services
        WHERE	invalid_date < SYSDATE;

        CURSOR c_service_actions IS
        SELECT	service_id id, service_name name
        FROM	xdp_services s
        WHERE	NOT EXISTS
        		(SELECT	1
        		FROM 	xdp_service_val_acts  sva
        		WHERE	sva.service_id = s.service_id
                AND		SYSDATE
                BETWEEN sva.valid_date
                AND nvl(sva.invalid_date,gc_max_date)
                );

        -- wi_mappping_proc validity need not be checked as there is
        -- foreign key constraint defined.

        CURSOR c_dservice_wi_map_proc IS
        SELECT	sva.service_id id, s.service_name name
        FROM	xdp_service_val_acts sva, xdp_services s
        WHERE	sva.service_id = s.service_id
        AND	sva.wi_mapping_type = gc_DYNAMIC
        AND	sva.wi_mapping_proc is NULL;
*/
--
--     After integration with inventory, the new way of validate wi_mapping_proc.
--     07/19/2001

       CURSOR c_dservice_wi_map_proc IS
        SELECT mtl.inventory_item_id id
             , mtl.organization_id organization_id
             , mtl.concatenated_segments name
        FROM xdp_service_val_acts sva
           , mtl_system_items_vl mtl
        WHERE sva.inventory_item_id = mtl.inventory_item_id
        AND sva.organization_id = mtl.organization_id
        AND sva.wi_mapping_type = gc_DYNAMIC
        AND sva.wi_mapping_proc is NULL;

    BEGIN
--
--  remove the following validations as part of integration with inventory
--  07/19/2001
--
/*
        v_first_time  := TRUE;
        FOR rec IN c_invalid_service_warn
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_INVALID_SERVICES');
                Print(v_text,gc_WARNING, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_WARNING, 'NAME','VALID_DATE',
                            'INVALID_DATE');

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_WARNING,
						rec.name, rec.valid_date, rec.invalid_date);

        END LOOP;

		EndOfTable(NOT v_first_time);

        v_first_time := TRUE;
        FOR rec IN c_service_actions
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_SERVICE_ACTIONS');
                Print(v_text,gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_ERROR, gc_ID, gc_NAME);

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_ERROR, rec.id, rec.name);

        END LOOP;

		EndOfTable(NOT v_first_time);

*/
        v_first_time := TRUE;
        FOR rec IN c_dservice_WI_MAP_PROC
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_DSERVICE_WI_MAP_PROC');
                Print(v_text,gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_ERROR, gc_ID, gc_NAME);

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_ERROR, rec.id, rec.name);

        END LOOP;

		EndOfTable(NOT v_first_time);

    EXCEPTION
       WHEN OTHERS THEN
          HandleError('SERVICE_VALIDATIONS', SQLCODE, SQLERRM);
    END SERVICE_VALIDATIONS;

    -- Message Name:
    --   XNP_CVU_INVALID_PACKAGES
    --       If valid_date is null or invalid_date < sysdate
    --          Removed after 11.5.6
    --   XNP_CVU_EMPTY_PACKAGEs
    --       Service package should have valid service defined for it
    --          Removed after 11.5.6

    PROCEDURE PACKAGE_VALIDATIONS
    IS
        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;

--
--  remove the following validations as part of integration with inventory
--  07/19/2001
--  Packages now reside in BOM  We have no good way to identify what BOMs are ours.
--  We can add checks against our packages in BOM later on.
--
/*
        CURSOR c_invalid_package_warn IS
        SELECT	package_id id, package_name name,
				to_char(valid_date, gc_DATE_FORMAT) valid_date,
                DECODE(invalid_date, NULL, gc_NULL,
					to_char(invalid_date, gc_DATE_FORMAT)) invalid_date
        FROM	xdp_service_packages
        WHERE	invalid_date < SYSDATE;

        CURSOR c_empty_packages IS
 	SELECT package_id id, package_name name
	FROM   xdp_service_packages sp
	WHERE  NOT EXISTS
		(SELECT 1
		 FROM 	xdp_service_pkg_det spd, xdp_services sv
		 WHERE  spd.package_id =  spd.package_id
		 AND    spd.service_id = sv.service_id
		 AND 	SYSDATE BETWEEN sv.valid_date
			AND nvl(sv.invalid_date,gc_max_date)
		);
*/

    BEGIN
        v_first_time  := TRUE;
--
--  remove the following validations as part of integration with inventory
--  07/19/2001
--  Packages now reside in BOM  We have no good way to identify what BOMs are ours.
--  We can add checks against our packages in BOM later on.
--
/*
        FOR rec IN c_invalid_package_warn
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_INVALID_PACKAGES');
                Print(v_text,gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_WARNING, gc_ID, gc_NAME,
                                gc_VALID_DATE, gc_INVALID_DATE);

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS,gc_WARNING, rec.id, rec.name,
								rec.valid_date, rec.invalid_date);

        END LOOP;

		EndOfTable(NOT v_first_time);

        v_first_time  := TRUE;
        FOR rec IN c_empty_packages
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_EMPTY_PACKAGES');
                Print(v_text,gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_WARNING, gc_ID, gc_NAME);

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS, gc_WARNING, rec.id, rec.name);

        END LOOP;

		EndOfTable(NOT v_first_time);
*/

    EXCEPTION
       WHEN OTHERS THEN
          HandleError('PACKAGE_VALIDATIONS', SQLCODE, SQLERRM);
    END PACKAGE_VALIDATIONS;


    --  Message Names
    --      XNP_CVU_VALID_WORKITEMS:
    --          If valid_date is null or invalid_date < sysdate
    --      XNP_CVU_STATIC_WI_NO_FE
    --          If work item is static then there should be FA configured for it.

    PROCEDURE WORK_ITEMS
    IS
        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;

        CURSOR  c_valid_wi IS
        SELECT	workitem_id id, workitem_name name,
				to_char(valid_date, gc_DATE_FORMAT) valid_date,
                DECODE(invalid_date, NULL, gc_NULL,
						to_char(invalid_date, gc_DATE_FORMAT)) invalid_date
        FROM	xdp_workitems
        WHERE	invalid_date < SYSDATE;

        CURSOR c_static_wi_no_fe IS
        SELECT	workitem_id id, workitem_name name
        FROM	xdp_workitems wi
        WHERE	wi.wi_type_code = gc_STATIC
        AND		NOT EXISTS
		      (SELECT	1
		      FROM		xdp_wi_fa_mapping wfa
		      WHERE		wfa.workitem_id = wi.workitem_id);

    BEGIN
        v_first_time  := TRUE;
        FOR rec IN c_valid_wi
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_VALID_WORKITEMS');
                Print(v_text,gc_ERROR, gc_CONTEXT);


                PrintReportDetails(gc_HEADING, gc_WARNING, gc_ID, gc_NAME,
                                gc_VALID_DATE, gc_INVALID_DATE);

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS, gc_WARNING, rec.id, rec.name,
								rec.valid_date, rec.invalid_date);

        END LOOP;

		EndOfTable(NOT v_first_time);

        v_first_time  := TRUE;
        FOR rec IN c_static_wi_no_fe
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_STATIC_WI_NO_FE');
                Print(v_text,gc_ERROR, gc_CONTEXT);


                PrintReportDetails(gc_HEADING, gc_ERROR, gc_ID, gc_NAME);

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS, gc_ERROR, rec.id, rec.name);

        END LOOP;

		EndOfTable(NOT v_first_time);

    EXCEPTION
       WHEN OTHERS THEN
          HandleError('WORK_ITEMS', SQLCODE, SQLERRM);
    END WORK_ITEMS;

    -- Message Name:
    --      XNP_CVU_ACTIVITY_BASED_TIMERS
    --          If there is a Timer associated with the event
    --          then it should subscribe to the same response

    PROCEDURE ACTIVITY_BASED_TIMERS
    IS
        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;

        CURSOR  c_timers IS
        SELECT  tp.timer_publisher_id, tp.source_message_code, tp.timer_message_code
        FROM	xnp_timer_publishers tp
        WHERE	NOT EXISTS
        	   (SELECT 1
        	   FROM    xnp_msg_acks ma
        	   WHERE   ma.source_msg_code = tp.source_message_code
        	   AND     ma.ack_msg_code = tp.timer_message_code );

    BEGIN
        v_first_time  := TRUE;
        FOR rec IN c_timers
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_ACTIVITY_BASED_TIMERS');
                Print(v_text,gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_ERROR, 'TIMER_PUBLISHER_ID',
									'SOURCE_MESSAGE_CODE', 'TIMER_MESSAGE_CODE');

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS, gc_ERROR, rec.timer_publisher_id,
						rec.source_message_code, rec.timer_message_code);

        END LOOP;

		EndOfTable(NOT v_first_time);

    EXCEPTION
       WHEN OTHERS THEN
          HandleError('ACTIVITY_BASED_TIMERS', SQLCODE, SQLERRM);
    END ACTIVITY_BASED_TIMERS;

    -- Message Name:
    --      XNP_CVU_UNCOMPILED_ISTUDIO_MSG

    PROCEDURE MESSAGE_COMPILATION
    IS
        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;

        CURSOR  c_msg_code IS
            SELECT  msg_code
            FROM    xnp_msg_types_b
	    WHERE   status = 'UNCOMPILED';

        v_error_code NUMBER;
        v_error_msg VARCHAR2(150);
        v_pkg_spec VARCHAR2(150);
        v_pkg_body VARCHAR2(150);
        v_synonym  VARCHAR2(150);

    BEGIN
        v_first_time  := TRUE;
        FOR rec IN c_msg_code
        LOOP
                IF v_first_time THEN
                    v_text := GetNumErrMsg('XNP_CVU_UNCOMPILED_ISTUDIO_MSG');
                    Print(v_text,gc_ERROR, gc_CONTEXT);
                	PrintReportDetails(gc_HEADING, gc_ERROR, 'MSG_CODE');

                	v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS, gc_ERROR, rec.msg_code);

        END LOOP;

		EndOfTable(NOT v_first_time);

    EXCEPTION
       WHEN OTHERS THEN
          HandleError('MESSAGE_COMPILATION', SQLCODE, SQLERRM);
    END MESSAGE_COMPILATION;


    -- Message Name:
    --      XNP_CVU_INALID_FP
    --          All Fulfillment Procedures must be VALID  objects.

    PROCEDURE INVALID_FP
    IS
        v_text VARCHAR2(1000);
        v_first_time BOOLEAN := TRUE;

        CURSOR  c_invalid_fp IS
        SELECT	distinct proc_name name
        FROM	xdp_proc_body pb, user_objects uo
        WHERE	uo.object_name = substr(pb.proc_name, 1, (INSTR(pb.proc_name,'.')-1))
        AND		uo.object_type in ('PACKAGE','PACKAGE BODY')
        AND     uo.status = 'INVALID';
    BEGIN
        v_first_time  := TRUE;
        FOR rec IN c_invalid_fp
        LOOP
            IF v_first_time THEN
                v_text := GetNumErrMsg('XNP_CVU_INVALID_FP');
                Print(v_text, gc_ERROR, gc_CONTEXT);

                PrintReportDetails(gc_HEADING, gc_ERROR, gc_NAME);

                v_first_time := FALSE;
            END IF;

            PrintReportDetails(gc_DETAILS, gc_ERROR, rec.name);

        END LOOP;

		EndOfTable(NOT v_first_time);

    EXCEPTION
       WHEN OTHERS THEN
          HandleError('INVALID_FP', SQLCODE, SQLERRM);
    END INVALID_FP;


    PROCEDURE CrossValidate(p_work_instance_id VARCHAR2,
                          p_message_code VARCHAR2,
                          p_LHS VARCHAR2,
                          p_RHS VARCHAR2,
                          p_error IN OUT NOCOPY BOOLEAN)
    IS
        v_lhs_msg VARCHAR2(100) default NULL;
        v_rhs_msg VARCHAR2(100) default NULL;
        v_text VARCHAR2(1000) default NULL;

        v_trace VARCHAR2(150) default NULL;
    BEGIN

    -- p_ERROR will be FALSE for the first time.
    -- SO it can be used to Print the Header.
    -- For subsequent errors Header can be avoided
    -- XNP_CVU_WF_LHS_NOT_VALID_ELEM -> ERROR

        v_trace := 'XNP_CVU_WF_LHS_NOT_VALID_ELEM';

        BEGIN
            SELECT	'XNP_CVU_WF_LHS_NOT_VALID_ELEM'
            INTO    v_lhs_msg
            FROM    dual
            WHERE	NOT EXISTS
                (SELECT	1
                FROM	xnp_msg_elements me
                WHERE	me.name = p_LHS
                AND		me.parameter_flag = 'Y'
                AND		me.msg_code = p_message_code);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_lhs_msg := NULL;
        END;

        -- XNP_CVU_WF_RHS_NOTVALID_PARAM  -> ERROR

        v_trace := 'XNP_CVU_WF_RHS_NOTVALID_PARAM';

        BEGIN
            SELECT 'XNP_CVU_WF_RHS_NOTVALID_PARAM'
             INTO    v_rhs_msg
             FROM dual
             WHERE NOT EXISTS
                 (SELECT 1
                        FROM fnd_lookups flk
                        WHERE flk.lookup_code =  p_RHS
                            AND flk.lookup_type = 'CSI_EXTEND_ATTRIB_POOL');
--
--	After 11.5.6, XDP_PARAMETER_POOL will be dropped and parameters are seededin FND_LOOKUPS
--      Hence the change.
--      07/19/2001
/*
          SELECT	'XNP_CVU_WF_RHS_NOTVALID_PARAM'
            INTO    v_rhs_msg
            FROM	dual
            WHERE	NOT EXISTS
                (SELECT	1
		      FROM	xdp_parameter_pool pol
                WHERE	pol.parameter_name =  p_RHS);
*/
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_rhs_msg := NULL;
        END;


        IF v_lhs_msg IS NOT NULL OR v_rhs_msg IS NOT NULL THEN

            IF v_lhs_msg IS NOT NULL THEN
                v_text := GetNumErrMsg('XNP_CVU_WF_LHS_NOT_VALID_ELEM'
                                               , 'MSG_ELEM'
                                               , p_lhs);
                Print(v_text,gc_ERROR,gc_MESSAGE);
				p_error := TRUE;
            END IF;

            IF v_rhs_msg IS NOT NULL THEN
                v_text := GetNumErrMsg('XNP_CVU_WF_RHS_NOTVALID_PARAM'
                                               , 'MSG_CODE'
                                               , p_rhs);
				Print(v_text, gc_ERROR,gc_MESSAGE);
				p_error := TRUE;
            END IF;

        END IF;

    EXCEPTION
           WHEN OTHERS THEN
                HandleError('CrossValidate:'||v_trace, SQLCODE, SQLERRM);
            RAISE;
    END CrossValidate;

    --  v_param_list: LHS1=$RHS1,LHS2=$RHS2,LHS3=RHS4

    PROCEDURE PerformCrossValidations (p_work_instance_id VARCHAR2,
                                    p_message_code VARCHAR2,
                                    p_param_list VARCHAR2,
									p_error IN OUT NOCOPY BOOLEAN)
    IS

        v_no_equal NUMBER    := 0;
        v_no_elements   NUMBER:= 0;

        v_current_pos NUMBER    := 0;
        v_equal_pos NUMBER    := 0;
        v_comma_pos NUMBER    := 0;

        v_LHS VARCHAR2(30) := NULL;
        v_RHS VARCHAR2(30) := NULL;

        v_all_processed BOOLEAN := FALSE;

        v_text VARCHAR2(1000);
        v_no_such_evt VARCHAR2(150);
    BEGIN

        BEGIN
            SELECT	'XNP_CVU_WF_NOT_VALID_EVT_TYPE'
            INTO    v_no_such_evt
            FROM    dual
            WHERE	NOT EXISTS
                (SELECT	1
                FROM	xnp_msg_types_b me
                WHERE   me.msg_code = p_message_code);

            IF v_no_such_evt IS NOT NULL THEN
                v_text := GetNumErrMsg('XNP_CVU_WF_NOT_VALID_EVT_TYPE',
									'MSG_CODE', p_message_code);
                Print(v_text ,gc_ERROR ,gc_MESSAGE);
				p_error := TRUE;
            END IF;


        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_no_such_evt := NULL;
        END;

        IF p_param_list IS NULL THEN
			/* This condition is not an error */
			null;
        ELSE
            v_no_equal := 0;
            v_current_pos := 1;
            v_all_processed  := FALSE;

            WHILE   NOT v_all_processed
            LOOP

                v_equal_pos := INSTR(p_param_list, '=',v_current_pos, 1);

                IF v_equal_pos = 0 THEN  -- Error Data
                    v_LHS := SUBSTR(p_param_list, v_current_pos, LENGTH(p_param_list));
                    v_RHS := NULL;

                    v_all_processed := TRUE;
                ELSE
                    v_no_equal := v_no_equal + 1;

                    v_comma_pos := INSTR(p_param_list, ',',v_current_pos, 1);

                    IF v_comma_pos = 0 THEN
                        v_comma_pos := LENGTH(p_param_list) + 1;  -- would be position
                        v_all_processed:= TRUE;
                    END IF;

                    v_LHS := SUBSTR(p_param_list,v_current_pos,
								v_equal_pos - v_current_pos);   -- Till '='
                    v_RHS := SUBSTR(p_param_list,v_equal_pos + 2 ,
								v_comma_pos - v_equal_pos - 2);  -- skip '=$' and ','

                    v_current_pos := v_comma_pos + 1;
                END IF;

                CrossValidate(p_work_instance_id,
                              p_message_code,
                              v_LHS,
                              v_RHS,
                              p_error);
            END LOOP;

            -- XNP_CVU_WF_PAIRS_GT_ELEM -> ERROR
            -- XNP_CVU_WF_PAIRS_LT_ELEM -> WARNING

            SELECT  count(*)
            INTO    v_no_elements
            FROM    xnp_msg_elements me
            WHERE   me.parameter_flag = 'Y'
            AND     me.msg_code = p_message_code;

            IF v_no_equal > v_no_elements THEN
                v_text := GetNumErrMsg('XNP_CVU_WF_PAIRS_GT_ELEM', v_no_equal, v_no_elements);
                Print(v_text,gc_ERROR,gc_MESSAGE);
				p_error := TRUE;
            ELSIF v_no_equal < v_no_elements THEN
                v_text := GetNumErrMsg('XNP_CVU_WF_PAIRS_LT_ELEM', v_no_equal, v_no_elements);
                Print(v_text,gc_WARNING,gc_MESSAGE);
				p_error := TRUE;
            END IF;
        END IF;

    EXCEPTION
           WHEN OTHERS THEN
              XNP_CVU_PKG.HandleError('PerformCrossValidations', SQLCODE, SQLERRM);

            RAISE;
    END PerformCrossValidations;


    -- Calls:   PerformCrossValidations -> CrossValidate
    -- Message Name:
    --      XNP_CVU_WF_LHS_NOT_VALID_ELEM
    --          Check that <<LHS>> is a valid parameter type element in the iMessage Studio
    --      XNP_CVU_WF_RHS_NOTVALID_PARAM
    --          Check that <<RHS>> is valid parameter name form SFM parameter pool
    --      XNP_CVU_WF_PAIRS_GT_ELEM (#EQUALS, #ELEMENTS)
    --      XNP_CVU_WF_PAIRS_LT_ELEM (#EQUALS, #ELEMENTS)
    --          <<No of parameter pairs>> defined for <<message code>> in the work flow
    --          is equal to the number of parameter type elements for the corresponding
    --          message defined in the iMessage Studio.  If it is more indicate "ERROR",
    --          if it is less indicate "WARNING".
    --      XNP_CVU_WF_NULL_PARAM
    --          Parameter string is NULL.

    -- Assumption
    --          Due to Order by clause, the query is expected to return the records in the
    --          following way.  Cae IV and similar are NOT handled by the program.
    --  Instance_id     Attribute
    --  CASE I
    --  1               EVENT_TYPE
    --  CASE II
    --  2               PARAM_LIST
    --  CASE III
    --  3               EVENT_TYPE
    --  3               PARAM_LIST
    --  CASE IV
    --  4               EVENT_TYPE
    --  4               EVENT_TYPE
    --  4               PARAM_LIST

    PROCEDURE WF_PP_MSG_CROSS_VALIDATION IS

	CURSOR  c_wi_processes
		IS
		SELECT	pat.process_name process_name,
				pat.process_item_type process_item_type,
				max(pat.process_version) process_version
		FROM	wf_process_activities pat, xdp_workitems wi
		WHERE
		-- xdp_workitem - process
				pat.process_name = wi.user_wf_process_name
		AND     pat.process_item_type = wi.user_wf_item_type
		-- Only work flow work items
		AND		wi.wi_type_code = gc_WORKFLOW
		GROUP BY 	pat.process_item_type, pat.process_name;

    CURSOR c_wf (p_process_name varchar2,
				p_process_item_type varchar2,
				p_process_version number) IS
        SELECT	pat.instance_id, pat.process_name,
				pat.process_item_type, pat.process_version,
	            atv.name attribute_name,
				atv.text_value attribute_value, pat.activity_name
        FROM	wf_process_activities pat, wf_activities ac, wf_activity_attr_values atv
        WHERE
		--  highest version for the process
				pat.process_name = p_process_name
		AND		pat.process_item_type = p_process_item_type
		AND		pat.process_version = p_process_version
		-- process to activites
		AND		ac.name = pat.activity_name
        AND		ac.item_type = pat.activity_item_type

        -- should consider only the max version AND		ac.version = pat.process_version
		-- alternatively less cleaner but easier approach is to
		-- pick up the record with end_date is null
        -- AND		ac.version = pat.process_version
		AND		ac.end_date IS NULL
		--<
        AND		pat.instance_id = atv.process_activity_id
        -- Only for PUBLISH_EVENT and SEND_MESSAGE functions
        AND		ac.function IN ('XNP_WF_STANDARD.PUBLISH_EVENT',
                                'XNP_WF_STANDARD.SEND_MESSAGE')
        -- Parameter attributes
        AND		atv.name IN  (gc_PARAM_LIST, gc_EVENT_TYPE)
        ORDER BY   pat.instance_id
                 , pat.process_name
                 , pat.process_item_type
                 , pat.process_version
                 , DECODE(atv.name, gc_EVENT_TYPE, 1, 2)
                 , atv.text_value;

        v_work_instance_id wf_process_activities.instance_id%TYPE := NULL;
        v_work_process_name wf_process_activities.process_name%TYPE := NULL;
        v_work_activity_name wf_process_activities.activity_name%TYPE := NULL;
        v_work_process_item_type wf_process_activities.process_item_type%TYPE := NULL;
        v_work_process_version wf_process_activities.process_version%TYPE := NULL;

		v_work_attribute_name  wf_activity_attr_values.name%TYPE := NULL;
		v_work_attribute_value  wf_activity_attr_values.text_value%TYPE := NULL;


        v_message_code VARCHAR2(150) := NULL;
        v_param_list VARCHAR2(150) := NULL;
		v_first_time BOOLEAN;
		v_error BOOLEAN;
    BEGIN

		v_first_time := TRUE;


		FOR processes_rec IN c_wi_processes
		LOOP
	        FOR rec IN c_wf(processes_rec.process_name,
							processes_rec.process_item_type,
							processes_rec.process_version)
	        LOOP

			-- Displays the key for the business rule
			-- displayed from the earlier iteration

				IF v_error THEN
		            PrintReportDetails(gc_HEADING, gc_ERROR,
							'PROCESS_ITEM_TYPE',
							'PROCESS_NAME',
							'ACTIVITY_NAME',
							'ATTRIBUTE_NAME',
							'ATTRIBUTE_VALUE');
					PrintReportDetails(gc_DETAILS, gc_ERROR,
										v_work_process_item_type,
	                                    v_work_process_name,
	                                    v_work_activity_name,
	                                    v_work_attribute_name,
										v_work_attribute_value);
					EndOFTable(True);
					v_error := FALSE;

				END IF;

	            -- New Process
	            IF  rec.instance_id <> v_work_instance_id OR
	                v_work_instance_id IS NULL
	            THEN
	            --  If only MESSAGE_CODE is defined and NO PARAM_LIST defined
	            --  then Validate before starting the NEW Process
	            -- CASE I
	                IF v_message_code IS NOT NULL THEN

	                    PerformCrossValidations(v_work_instance_id,
	                                        v_message_code,
	                                        replace(v_param_list,' ',''),
											v_error);

	                   v_message_code := NULL;
	                   v_param_list := NULL;
	               END IF;

	            --- Store Work Process Key
	              v_work_instance_id := rec.instance_id;
	              v_work_process_name := rec.process_name;
	              v_work_process_item_type := rec.process_item_type;
	              v_work_process_version := rec.process_version;
	              v_work_activity_name := rec.activity_name;

				  v_work_attribute_name := rec.attribute_name;
				  v_work_attribute_value := rec.attribute_value;

	            --- Get MESSAGE CODE
	              IF rec.attribute_name  = gc_EVENT_TYPE THEN
	                  v_message_code := rec.attribute_value;
	              END IF;


	            --  Get PARAM LIST in the next iteration

	              IF rec.attribute_name = gc_PARAM_LIST THEN

	                -- At this step it means that
	                -- PARAM_LIST is defined but  MESSAGE_CODE is not defined

	                --  CASE III

	                    v_param_list := rec.attribute_value;

	                    PerformCrossValidations(v_work_instance_id,
	                                        v_message_code,
	                                        replace(v_param_list,' ',''),
											v_error);

	                    v_message_code := NULL;
	                    v_param_list := NULL;
	              END IF;
	            -- Second iteration for the same process
	            ELSE
	                IF rec.attribute_name = gc_PARAM_LIST THEN

	                -- At this step it means that
	                -- PARAM_LIST  and MESSAGE_CODE are both defined

	                    v_param_list := rec.attribute_value;

	                    PerformCrossValidations(v_work_instance_id,
	                                        v_message_code,
	                                        replace(v_param_list,' ',''),
											v_error);

	                   v_message_code := NULL;
	                   v_param_list := NULL;

	                ELSE
	                    -- CASE IV
	                    -- Program should never enter here
	                    Print('WF_PP_MSG_CROSS_VALIDATION'|| '**CASE IV**');
	                END IF;
	            END IF;
			END LOOP;

        END LOOP;

		IF v_error THEN
			PrintReportDetails(gc_HEADING, gc_ERROR,
					'PROCESS_ITEM_TYPE',
					'PROCESS_NAME',
					'ACTIVITY_NAME',
					'ATTRIBUTE_NAME',
					'ATTRIBUTE_VALUE');
			PrintReportDetails(gc_DETAILS, gc_ERROR,
					v_work_process_item_type,
					v_work_process_name,
					v_work_activity_name,
					v_work_attribute_name,
					v_work_attribute_value);
			EndOFTable(True);
			v_error := FALSE;

		END IF;

    EXCEPTION
           WHEN OTHERS THEN
		-- dbms_output.put_line(' Exception block ');
              XNP_CVU_PKG.HandleError('WF_PP_MSG_CROSS_VALIDATION', SQLCODE, SQLERRM);
    END WF_PP_MSG_CROSS_VALIDATION;

    -- Message Name:
    --      XNP_CVU_WF_NO_RQD_ITEM_ATT
    --      For user defined work flows, ORDER_ID, WORKITEM_INSTANCE_ID,
    --          LINE_ITEM_IDitem attributes must be defined

    PROCEDURE WF_NO_RQD_ITEM_ATT IS

    CURSOR c_no_special_ia IS

         SELECT DISTINCT wi.user_wf_item_type item_type , workitem_name
         FROM   xdp_workitems wi
         WHERE  wi.wi_type_code = 'WORKFLOW'
         AND    wi.user_wf_item_type IS NOT NULL
         AND    ( NOT EXISTS
                  (SELECT 1
                   FROM   wf_item_attributes ia
                   WHERE  ia.name      = 'ORDER_ID'
                   AND    ia.item_type = wi.user_wf_item_type
                  )
                OR NOT EXISTS
                  (SELECT 1
                   FROM   wf_item_attributes ia
                   WHERE  ia.name      = 'WORKITEM_INSTANCE_ID'
                   AND    ia.item_type = wi.user_wf_item_type
                  )
                OR NOT EXISTS
                  (SELECT 1
                   FROM   wf_item_attributes ia
                   WHERE  ia.name      = 'LINE_ITEM_ID'
                   AND    ia.item_type = wi.user_wf_item_type
                  )
                );

                v_first_time BOOLEAN := TRUE;
                v_text VARCHAR2(1000) := NULL;
    BEGIN

        v_first_time  := TRUE;
        FOR rec IN  c_no_special_ia
        LOOP

			IF v_first_time = TRUE THEN
				v_text := GetNumErrMsg('XNP_CVU_WF_NO_RQD_ITEM_ATT');
	            Print(v_text, gc_OK, gc_CONTEXT);

				PrintReportDetails(gc_HEADING, gc_ERROR, 'ITEM_TYPE', 'WORKITEM_NAME');
	            v_first_time := FALSE;
			END IF;

			PrintReportDetails(gc_DETAILS, gc_ERROR, rec.item_type, rec.workitem_name);

		END LOOP;

		EndOfTable(NOT v_first_time);

    EXCEPTION
       WHEN OTHERS THEN
          XNP_CVU_PKG.HandleError('WF_NO_RQD_ITEM_ATT', SQLCODE, SQLERRM);
    END WF_NO_RQD_ITEM_ATT;


    FUNCTION ActivityExists(p_act_name VARCHAR2,
                            p_process_name varchar2,
                            p_process_item_type varchar2,
                            p_process_version number)
    RETURN NUMBER
    IS
        v_count NUMBER := 0;
    BEGIN
        SELECT     COUNT(*)
        INTO    v_count
        FROM    wf_process_activities pat
        WHERE	pat.process_name = p_process_name
 		AND		pat.process_item_type = p_process_item_type
        AND     pat.process_version = p_process_version
        AND     pat.activity_name = p_act_name;

        return v_count;

    EXCEPTION
       WHEN OTHERS THEN
          XNP_CVU_PKG.HandleError('ActivityExists', SQLCODE, SQLERRM);
          RAISE;
    END ActivityExists;


    -- XNP_CVU_EXECUTE_FA_FA_NAME
    -- XNP_CVU_EXECUTE_FA_FE_NAME

    PROCEDURE CheckAttrValues(p_instance_id NUMBER,
                    p_text1 IN OUT NOCOPY VARCHAR2,
                    p_text2 IN OUT NOCOPY VARCHAR2)
    IS
        v_text_value VARCHAR2(1000);
        v_count NUMBER := 0;
    BEGIN

        -- XNP_CVU_EXECUTE_FA_FA_NAME
        BEGIN
            SELECT  text_value
            INTO    v_text_value
            FROM    wf_activity_attr_values
            WHERE   process_activity_id = p_instance_id
            AND     NAME = gc_FA_NAME;

            IF v_text_value IS NULL
            THEN
                p_text1 := 'XNP_CVU_EXECUTE_FA_FA_NAME';
            ELSE
               SELECT  count(*)
                INTO    v_count
                FROM    xdp_fulfill_actions
                WHERE   fulfillment_action = v_text_value;

                IF v_count = 0 THEN
                    p_text1 := 'XNP_CVU_EXECUTE_FA_FA_NAME';
                END IF;
            END IF;


        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                    p_text1 := 'XNP_CVU_EXECUTE_FA_FA_NAME';
            WHEN OTHERS THEN
                    raise;
        END;

        -- XNP_CVU_EXECUTE_FA_FE_NAME
        BEGIN
            SELECT  text_value
            INTO    v_text_value
            FROM    wf_activity_attr_values
            WHERE   process_activity_id = p_instance_id
            AND     NAME = gc_FE_NAME;

            IF v_text_value IS NOT NULL
            THEN
                SELECT  count(*)
                INTO    v_count
                FROM    xdp_fes
                WHERE   fulfillment_element_name = v_text_value;

                IF v_count = 0 THEN
                    p_text2 := 'XNP_CVU_EXECUTE_FA_FE_NAME';
                END IF;
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                null;
            WHEN  OTHERS THEN
                raise;
        END;

    EXCEPTION
       WHEN OTHERS THEN
          XNP_CVU_PKG.HandleError('CheckAttrValues', SQLCODE, SQLERRM);
          RAISE;
    END CheckAttrValues;


    -- Message Name:
    --      XNP_CVU_WF_NO_COMP_WI_USTATUS
    --          User defined Work Flow should have the activity  "COMPLETE_WI_UPDATE_STATUS"
    --          in all the end paths of the process.
    --      XNP_CVU_WF_PROVISION_FE
    --          For user defined workflows, If activity "PROVISON_FE" is defined
    --          then "CREATE_SMS_PORTING_RECORD" and "WAIT_FOR_RESPONSE" must be defined.
    --      XNP_CVU_WF_DEPROVISION_FE
    --          For user defined workflows, If activity "PROVISON_FE" is defined
    --          then "CREATE_SMS_PORTING_RECORD" and "WAIT_FOR_RESPONSE" must be defined.
    --      XNP_CVU_WF_FIRE_REMOVE
    --          For user defined workflows, If activity "Fire Timer" is defined
    --          then "Remove Timer" must be defined
    --      XNP_CVU_EXEUTE_FA
    --          IF EXECUTE_FA activity is defined then following must be true:
    --      XNP_CVU_EXECUTE_FA_FA_NAME
    --          FA_NAME must be defined and should be NOT NULL and Valid FA.
    --      XNP_CVU_EXECUTE_FA_FE_NAME
    --          FE_NAME must be valid if defined.

    PROCEDURE WF_SPECIAL_ACTIVITIES
        IS
        CURSOR  c_wi_processes
        IS
        SELECT	pat.process_item_type, pat.process_name, max(pat.process_version) process_version
        FROM	wf_process_activities pat, xdp_workitems wi
        WHERE
   	    -- xdp_workitem - process
                pat.process_name = wi.user_wf_process_name
        AND     pat.process_item_type = wi.user_wf_item_type
        -- Only work flow work items
        AND		wi.wi_type_code = gc_WORKFLOW
		GROUP BY 	pat.process_item_type, pat.process_name;


		-- Used for CVU_EXECUTE_FA validation
		-- Limitation: Wouldn't work if there is same activity from different item_types in the same
		-- process. Unlikely but possible scenario.

		CURSOR	c_wf_activities ( p_process_name varchar2,
								p_process_item_type varchar2,
								p_process_version number)
		IS
		SELECT	pat.instance_id
		FROM	wf_process_activities pat
		WHERE	pat.process_name = p_process_name
		AND		pat.process_item_type = p_process_item_type
		AND		pat.process_version = p_process_version
		AND		pat.activity_name = gc_EXECUTE_FA;

        v_first_time BOOLEAN := TRUE;

        v_text VARCHAR2(1000) := NULL;
        v_err_text1 VARCHAR2(150) := NULL;
        v_err_text2 VARCHAR2(150) := NULL;

        v_comp_wi_upd_stat_cnt NUMBER := 0;
        v_end_cnt NUMBER := 0;
        v_provision_fe_cnt NUMBER := 0;
        v_deprovision_fe_cnt NUMBER := 0;
        v_fire_cnt NUMBER := 0;
        v_remove_cnt NUMBER := 0;

    BEGIN


        -- XNP_CVU_WF_NO_COMP_WI_USTATUS
        v_first_time := TRUE;
        FOR rec IN c_wi_processes
        LOOP
            -- count the no. of COMP WI update stat and END activities
            -- The counts should match for each process
            v_comp_wi_upd_stat_cnt :=
              ActivityExists(gc_COMPLETE_WI_UPDATE_STATUS,
							rec.process_name,
                            rec.process_item_type,
                            rec.process_version);
            v_end_cnt :=
              ActivityExists(gc_XDP_END,
							rec.process_name,
                            rec.process_item_type,
                            rec.process_version) +
              ActivityExists(gc_END,
							rec.process_name,
                            rec.process_item_type,
                            rec.process_version)
			 ;
			-- Sometimes for performance, XDP_END is used instead of END as END does additional checks
			-- so check is made on count of END or XDP_END.
            IF ((v_comp_wi_upd_stat_cnt - v_end_cnt) <> 0)
            THEN
                IF v_first_time THEN
                    v_text := GetNumErrMsg('XNP_CVU_WF_NO_COMP_WI_USTATUS');
                    Print(v_text,gc_ERROR, gc_CONTEXT);

					PrintReportDetails(gc_HEADING, gc_ERROR,
							'PROCESS_ITEM_TYPE', 'PROCESS_NAME',  'PROCESS_VERSION');
	            	v_first_time := FALSE;
                END IF;

				PrintReportDetails(gc_DETAILS, gc_ERROR,
							rec.process_item_type, rec.process_name, rec.process_version);
			END IF;

            v_comp_wi_upd_stat_cnt := 0;
            v_end_cnt := 0;

		END LOOP;

		EndOfTable(NOT v_first_time);
-- Message Names:
    -- XNP_CVU_EXEUTE_FA - Header Message
    -- XNP_CVU_EXECUTE_FA_FA_NAME
    -- XNP_CVU_EXECUTE_FA_FE_NAME

        v_first_time := TRUE;
        FOR rec IN c_wi_processes
        LOOP


			FOR ac_rec IN c_wf_activities( rec.process_name,
										rec.process_item_type,
										rec.process_version)
			LOOP

                CheckAttrValues(ac_rec.instance_id, v_err_text1, v_err_text2);

                IF v_err_text1 IS NOT NULL OR v_err_text2 IS NOT NULL
                THEN

                    IF v_first_time THEN
                        v_text := GetNumErrMsg('XNP_CVU_EXECUTE_FA');
                        Print(v_text,gc_ERROR, gc_MESSAGE);
						PrintReportDetails(gc_HEADING, gc_ERROR,
							'PROCESS_ITEM_TYPE', 'PROCESS_NAME',  'PROCESS_VERSION',
							'INSTANCE_ID',
							'ERROR');
                        v_first_time := FALSE;
                    END IF;

                    IF v_err_text1 IS NOT NULL THEN
						PrintReportDetails(gc_DETAILS, gc_ERROR,
							rec.process_item_type, rec.process_name, rec.process_version,
							ac_rec.instance_id,
							v_err_text1);
                    END IF;

                    IF v_err_text2 IS NOT NULL THEN
						PrintReportDetails(gc_DETAILS, gc_ERROR,
							rec.process_item_type, rec.process_name, rec.process_version,
							ac_rec.instance_id,
							v_err_text2);
                    END IF;

                END IF;
            END LOOP;
        END LOOP;
		EndOfTable(NOT v_first_time);

        -- XNP_CVU_WF_PROVISION_FE
        v_first_time := TRUE;
        FOR rec IN c_wi_processes
        LOOP
            v_provision_fe_cnt :=  ActivityExists(gc_PROVISION_FE,
												rec.process_name,
												rec.process_item_type,
												rec.process_version) ;
            IF v_provision_fe_cnt > 0
            AND
                    (ActivityExists(gc_CREATE_SMS_PORTING_RECORD,
						rec.process_name,
                        rec.process_item_type,
                        rec.process_version) = 0
                     OR
                        ActivityExists(gc_WAITFORFLOW,
						rec.process_name,
                        rec.process_item_type,
                        rec.process_version) <> v_provision_fe_cnt)
            THEN
                IF v_first_time THEN
                    v_text := GetNumErrMsg('XNP_CVU_WF_PROVISION_FE');
                    Print(v_text,gc_ERROR, gc_CONTEXT);
					PrintReportDetails(gc_HEADING, gc_ERROR,
							'PROCESS_ITEM_TYPE', 'PROCESS_NAME',  'PROCESS_VERSION');

                    v_first_time := FALSE;
                END IF;

				PrintReportDetails(gc_DETAILS, gc_ERROR,
							rec.process_item_type, rec.process_name, rec.process_version);
            END IF;
            v_provision_fe_cnt := 0;
        END LOOP;
		EndOfTable(NOT v_first_time);

        -- XNP_CVU_WF_DEPROVISION_FE
        v_first_time := TRUE;
        FOR rec IN c_wi_processes
        LOOP
            v_deprovision_fe_cnt :=  ActivityExists(gc_DEPROVISION_FE,
						rec.process_name,
                        rec.process_item_type,
                        rec.process_version) ;
            IF v_deprovision_fe_cnt > 0
            AND
                        ActivityExists(gc_WAITFORFLOW,
						rec.process_name,
                        rec.process_item_type,
                        rec.process_version) <> v_deprovision_fe_cnt
            THEN
                IF v_first_time THEN
                    v_text := GetNumErrMsg('XNP_CVU_WF_DEPROVISION_FE');
                    Print(v_text, gc_CONTEXT, gc_CONTEXT);
					PrintReportDetails(gc_HEADING, gc_ERROR,
							'PROCESS_ITEM_TYPE', 'PROCESS_NAME',  'PROCESS_VERSION');

                    v_first_time := FALSE;
                END IF;

				PrintReportDetails(gc_DETAILS, gc_ERROR,
							rec.process_item_type, rec.process_name, rec.process_version);
            END IF;
            v_deprovision_fe_cnt := 0;
        END LOOP;
		EndOfTable(NOT v_first_time);

        -- XNP_CVU_WF_FIRE_REMOVE
        v_first_time := TRUE;
        FOR rec IN c_wi_processes
        LOOP
            v_fire_cnt := ActivityExists(gc_FIRE,
						rec.process_name,
                        rec.process_item_type,
                        rec.process_version);

            v_remove_cnt :=  ActivityExists(gc_REMOVE,
						rec.process_name,
                        rec.process_item_type,
                        rec.process_version);

            IF (v_fire_cnt > v_remove_cnt)
            THEN
                IF v_first_time THEN
                    v_text := GetNumErrMsg('XNP_CVU_WF_FIRE_REMOVE');
                    Print(v_text,gc_WARNING,gc_CONTEXT);
					PrintReportDetails(gc_HEADING, gc_ERROR,
							'PROCESS_ITEM_TYPE', 'PROCESS_NAME',  'PROCESS_VERSION');

                    v_first_time := FALSE;
                END IF;
				PrintReportDetails(gc_DETAILS, gc_ERROR,
							rec.process_item_type, rec.process_name, rec.process_version);
            END IF;
            v_deprovision_fe_cnt := 0;
        END LOOP;
		EndOfTable(NOT v_first_time);

    EXCEPTION
       WHEN OTHERS THEN
          XNP_CVU_PKG.HandleError('WF_SPECIAL_ACTIVITIES', SQLCODE, SQLERRM);
    END WF_SPECIAL_ACTIVITIES;


    -- MESSABE NAMES:
    --      XNP_CVU_SUBSCRIBE_TO_BUS_EVTS
    --          Workflow activity  outcome value must be same
    --          as the event that is being submitted to

    PROCEDURE SUBSCRIBE_TO_BUSINESS_EVENTS
    IS
        CURSOR  c_wi_processes
        IS
        SELECT	pat.process_name process_name,
				pat.process_item_type process_item_type,
				max(pat.process_version) process_version
        FROM	wf_process_activities pat, xdp_workitems wi
        WHERE
   	    -- xdp_workitem - process
                pat.process_name = wi.user_wf_process_name
        AND     pat.process_item_type = wi.user_wf_item_type
        -- Only work flow work items
        AND		wi.wi_type_code = gc_WORKFLOW
		GROUP BY 	pat.process_item_type, pat.process_name;


        CURSOR c_activities(p_process_name varchar2,
							p_process_item_type varchar2,
							p_process_version number)
        IS

        SELECT	pa.instance_id, pa.process_item_type,
				pa.process_name, pa.process_version, ats.result_code
        FROM	wf_process_activities pa,
                wf_activity_transitions ats
        WHERE
        --  process_activities
                pa.process_name = p_process_name
        AND		pa.process_item_type = p_process_item_type
        AND		pa.process_version = p_process_version
        --  process_activities -> activity_transitions
        AND		ats.from_process_activity = pa.instance_id
        --  filters
        AND		pa.activity_name = gc_SUBSCRIBE_TO_BUSS_EVTS
		AND		ats.result_code  <> '*'
        AND NOT EXISTS
        (
        SELECT	1
        FROM	wf_activity_attr_values ack_aav
        WHERE	ack_aav.process_activity_id = pa.instance_id
        AND		ack_aav.name = gc_EVENT_TYPE
        AND		ack_aav.text_value = ats.result_code)
		ORDER BY  pa.process_item_type, pa.process_name, pa.process_version;

        v_first_time BOOLEAN := TRUE;
        v_text VARCHAR2(1000) := NULL;

    BEGIN

        v_first_time  := TRUE;

        FOR processes_rec IN  c_wi_processes
		LOOP
	        FOR rec IN  c_activities(processes_rec.process_name,
								processes_rec.process_item_type,
								processes_rec.process_version)
        	LOOP
	            IF v_first_time THEN
	                v_text := GetNumErrMsg('XNP_CVU_SUBSCRIBE_TO_BUS_EVTS');
	                Print(v_text,gc_ERROR, gc_CONTEXT);

					PrintReportDetails(gc_HEADING, gc_ERROR,
								'INSTANCE_ID', 'PROCESS_ITEM_TYPE',
								'PROCESS_NAME', 'PROCESS_VERSION', 'RESULT_CODE');
	                v_first_time := FALSE;
	            END IF;

				PrintReportDetails(gc_DETAILS, gc_ERROR,
								rec.instance_id, rec.process_item_type,
								rec.process_name, rec.process_version,  rec.result_code);

	        END LOOP;
		END LOOP;

		EndOfTable(NOT v_first_time);

    EXCEPTION
           WHEN OTHERS THEN
              XNP_CVU_PKG.HandleError('SUBSCRIBE_TO_BUSINESS_EVENTS', SQLCODE, SQLERRM);
    END SUBSCRIBE_TO_BUSINESS_EVENTS;


    -- MESSABE NAMES:
    --      XNP_CVU_SUBSCRIBE_TO_ACKS
    --          All the activity outcomes must the subset of the
    --          susbcribed events or messages or timers

    PROCEDURE SUBSCRIBE_TO_ACKS
    IS
        CURSOR  c_wi_processes
        IS
        SELECT	pat.process_name process_name,
				pat.process_item_type process_item_type,
				max(pat.process_version) process_version
        FROM	wf_process_activities pat, xdp_workitems wi
        WHERE
   	    -- xdp_workitem - process
                pat.process_name = wi.user_wf_process_name
        AND     pat.process_item_type = wi.user_wf_item_type
        -- Only work flow work items
        AND		wi.wi_type_code = gc_WORKFLOW
		GROUP BY 	pat.process_item_type, pat.process_name;


        CURSOR c_activities(p_process_name varchar2,
							p_process_item_type varchar2,
							p_process_version number)
        IS
        SELECT	pa.instance_id, pa.process_item_type,
				pa.process_name, pa.process_version, ats.result_code
        FROM	wf_process_activities pa,
                wf_activity_transitions ats
        WHERE
        --  process_activities
                pa.process_name = p_process_name
        AND		pa.process_item_type = p_process_item_type
        AND		pa.process_version = p_process_version
        --  process_activities -> activity_transitions
        AND		ats.from_process_activity = pa.instance_id
        --  filters
        AND		pa.activity_name = gc_SUBSCRIBE_TO_ACKS
        AND		ats.result_code <> '*'
        AND NOT EXISTS
        (
		SELECT	1
        FROM	wf_activity_attr_values ack_aav, xnp_msg_acks ack_xma
        WHERE
        -- Join with the outer SQL
        		ack_aav.process_activity_id = pa.instance_id
        AND		ack_xma.ack_msg_code = ats.result_code
        -- filter for attribute name
        AND		ack_aav.name = gc_EVENT_TYPE
        --  activity_attr_values -> xnp_msg_acks
        AND		ack_aav.text_value = ack_xma.source_msg_code)

		ORDER BY  pa.process_item_type, pa.process_name, pa.process_version;

        v_first_time BOOLEAN := TRUE;
        v_text VARCHAR2(1000) := NULL;

    BEGIN

        v_first_time  := TRUE;

        FOR processes_rec IN  c_wi_processes
		LOOP
	        FOR rec IN  c_activities(processes_rec.process_name,
								processes_rec.process_item_type,
								processes_rec.process_version)
	        LOOP
	            IF v_first_time THEN
	                v_text := GetNumErrMsg('XNP_CVU_SUBSCRIBE_TO_ACKS');
	                Print(v_text,gc_ERROR, gc_CONTEXT);

					PrintReportDetails(gc_HEADING, gc_ERROR,
								'INSTANCE_ID','PROCESS_ITEM_TYPE',
								'PROCESS_NAME', 'PROCESS_VERSION', 'RESULT_CODE');
	                v_first_time := FALSE;
	            END IF;

				PrintReportDetails(gc_DETAILS, gc_ERROR,
								rec.instance_id, rec.process_item_type,
								rec.process_name, rec.process_version, rec.result_code);
	        END LOOP;
		END LOOP;

		EndOfTable(NOT v_first_time);


    EXCEPTION
       WHEN OTHERS THEN
          XNP_CVU_PKG.HandleError('SUBSCRIBE_TO_ACKS', SQLCODE, SQLERRM);
    END SUBSCRIBE_TO_ACKS;


    FUNCTION ReloadRequired(p_fnd_lookup_type VARCHAR2,
                        p_wf_lookup_type VARCHAR2)
    RETURN BOOLEAN
    IS
        v_cnt NUMBER;
    BEGIN

        SELECT  count(*)
        INTO    v_cnt
        FROM    fnd_lookups fl
        WHERE   lookup_type = p_fnd_lookup_type
        AND     NOT EXISTS
                (SELECT 1
                FROM    wf_lookups wl
                WHERE   substr(wl.lookup_code,1,29) = substr(fl.lookup_code,1, 29)
                AND     nvl(substr(wl.meaning,1,75),'#') = nvl(substr(fl.meaning, 1,75),'#')
                AND     nvl(substr(wl.description,1,239),'#') = nvl(substr(fl.description, 1, 239),'#')
                AND     wl.lookup_type = p_wf_lookup_type);

        IF v_cnt > 0 THEN
            return TRUE;
        ELSE
            return FALSE;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            HandleError('ReloadRequired', SQLCODE, SQLERRM);
            RAISE;
    END ReloadRequired;


    -- Message Name
    --      XNP_CVU_WF_LOOKUP_CODES
    --      Lookup codes in the workflow DO NOT match the SFM configuration.
    --      Re-run the lookup code loader API.

    PROCEDURE WF_LOOKUP_CODES
    IS
        v_reload_flag BOOLEAN;
		v_failure VARCHAR2(1000) := NULL;
        v_cnt NUMBER;
        v_text VARCHAR2(1000) := NULL;
		v_delim VARCHAR2(100) := '    ';
    BEGIN

        IF ReloadRequired('XNP_CHANGE_CAUSE_CODE', 'STATUS_CHANGE_CAUSE')
        THEN
                v_reload_flag := TRUE;
				v_failure := 'STATUS_CHANGE_CAUSE';
        END IF;

		IF ReloadRequired('GET_CONSUMER_FE', 'GET_CONSUMER_FE')
        THEN
                v_reload_flag := TRUE;
				v_failure := v_failure ||v_delim|| 'GET_CONSUMER_FE';
        END IF;

        IF ReloadRequired('XNP_FEATURE_TYPE', 'FEATURE_TYPE')
        THEN
                v_reload_flag := TRUE;
				v_failure := v_failure ||v_delim|| 'FEATURE_TYPE';
        END IF;

        IF ReloadRequired('XNP_PHASE_INDICATOR', 'PORTING_PHASE')
        THEN
                v_reload_flag := TRUE;
				v_failure := v_failure  ||v_delim|| 'PORTING_PHASE';
        END IF;

        IF ReloadRequired('GET_RECEIVER_NAME', 'GET_RECEIVER_NAME')
        THEN
                v_reload_flag := TRUE;
				v_failure := v_failure  ||v_delim|| 'GET_RECEIVER_NAME';
        END IF;

        -- FE_NAME

        SELECT  count(*)
        INTO    v_cnt
        FROM    xdp_fes_vl fe
        WHERE   NOT EXISTS
                (SELECT 1
                FROM    wf_lookups wl
                WHERE   substr(wl.lookup_code,1,29) = substr(fe.fulfillment_element_name,1, 29)
                AND     nvl(substr(wl.meaning,1,75),'#') = nvl(substr(fe.display_name, 1,75),'#')
                AND     nvl(substr(wl.description,1,239),'#') = nvl(substr(fe.description, 1, 239),'#')
                AND     wl.lookup_type = 'FE_NAME');

        IF v_cnt <> 0 THEN
            v_reload_flag := TRUE;
			v_failure := v_failure ||v_delim|| 'FE_NAME';
        END IF;

        -- FA_NAME

        SELECT  count(*)
        INTO    v_cnt
        FROM    xdp_fulfill_actions_vl fa
        WHERE   NOT EXISTS
                (SELECT 1
                FROM    wf_lookups wl
                WHERE   substr(wl.lookup_code,1,29) = substr(fa.fulfillment_action,1, 29)
                AND     nvl(substr(wl.meaning,1,75),'#') = nvl(substr(fa.display_name, 1,75),'#')
                AND     nvl(substr(wl.description,1,239),'#') = nvl(substr(fa.description, 1, 239),'#')
                AND     wl.lookup_type = 'FA_NAME');

        IF v_cnt <> 0 THEN
            v_reload_flag := TRUE;
			v_failure := v_failure ||v_delim|| 'FA_NAME';
        END IF;

        -- MESSAGE_TYPE

        SELECT  count(*)
        INTO    v_cnt
        FROM    xnp_msg_types_vl mt
        WHERE   NOT EXISTS
                (SELECT 1
                FROM    wf_lookups wl
                WHERE   substr(wl.lookup_code,1,29) = substr(mt.msg_code,1, 29)
                AND     nvl(substr(wl.meaning,1,75),'#') = nvl(substr(mt.display_name, 1,75),'#')
                AND     nvl(substr(wl.description,1,239),'#') = nvl(substr(mt.description, 1, 239),'#')
                AND     wl.lookup_type = 'MESSAGE_TYPE');

        IF v_cnt <> 0 THEN
            v_reload_flag := TRUE;
			v_failure := v_failure ||v_delim|| 'MESSAGE_TYPE';
        END IF;

        -- TIMER_NAMES

        SELECT  count(*)
        INTO    v_cnt
        FROM    xnp_msg_types_vl mt
        WHERE   msg_type = 'TIMER'
        AND     NOT EXISTS
                (SELECT 1
                FROM    wf_lookups wl
                WHERE   substr(wl.lookup_code,1,29) = substr(mt.msg_code,1, 29)
                AND     nvl(substr(wl.meaning,1,75),'#') = nvl(substr(mt.display_name, 1,75),'#')
                AND     nvl(substr(wl.description,1,239),'#') = nvl(substr(mt.description, 1, 239),'#')
                AND     wl.lookup_type = 'TIMER_NAMES');

        IF v_cnt <> 0 THEN
            v_reload_flag := TRUE;
			v_failure := v_failure ||v_delim|| 'TIMER_NAMES';
        END IF;


        -- CUSTOMIZED_NOTN_MESSAGES

        SELECT  count(*)
        INTO    v_cnt
        FROM    fnd_new_messages nm
        WHERE   message_name like 'X%_NOTFN_%'
        AND     NOT EXISTS
                (SELECT 1
                FROM    wf_lookups wl
                WHERE   substr(wl.lookup_code,1,29) = substr(nm.message_name,1, 29)
                AND     nvl(substr(wl.meaning,1,75),'#') = nvl(substr(nm.description, 1,75),'#')
                AND     nvl(substr(wl.description,1,239),'#') = nvl(substr(nm.description, 1, 239),'#')
                AND     wl.lookup_type = 'CUSTOMIZED_NOTN_MESSAGES');

        IF v_cnt <> 0 THEN
            v_reload_flag := TRUE;
			v_failure := v_failure ||v_delim|| 'CUSTOMIZED_NOTN_MESSAGES';
        END IF;

        -- STATUS

        SELECT  count(*)
        INTO    v_cnt
        FROM    xnp_sv_status_types_vl sst
        WHERE   NOT EXISTS
                (SELECT 1
                FROM    wf_lookups wl
                WHERE   substr(wl.lookup_code,1,29) = substr(sst.status_type_code,1, 29)
                AND     nvl(substr(wl.meaning,1,75),'#') = nvl(substr(sst.display_name, 1,75),'#')
                AND     nvl(substr(wl.description,1,239),'#') = nvl(substr(sst.description, 1, 239),'#')
                AND     wl.lookup_type = 'STATUS');

        IF v_cnt <> 0 THEN
            v_reload_flag := TRUE;
			v_failure := v_failure ||v_delim|| 'STATUS';
        END IF;

        -- WORKITEM

        SELECT  count(*)
        INTO    v_cnt
        FROM    xdp_workitems_vl wi
        WHERE   NOT EXISTS
                (SELECT 1
                FROM    wf_lookups wl
                WHERE   substr(wl.lookup_code,1,29) = substr(wi.workitem_name,1, 29)
                AND     nvl(substr(wl.meaning,1,75),'#') = nvl(substr(wi.display_name, 1,75),'#')
                AND     nvl(substr(wl.description,1,239),'#') = nvl(substr(wi.description, 1, 239),'#')
                AND     wl.lookup_type = 'WORKITEM');

        IF v_cnt <> 0 THEN
            v_reload_flag := TRUE;
			v_failure := v_failure ||v_delim|| 'WORKITEM';
        END IF;

        -- Display Error

        IF v_reload_flag THEN
             v_text := GetNumErrMsg('XNP_CVU_WF_LOOKUP_CODES');
             Print(v_text,gc_WARNING, gc_MESSAGE);
             Print(v_failure,gc_WARNING, gc_MESSAGE);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            HandleError('WF_LOOKUP_CODES', SQLCODE, SQLERRM);
    END WF_LOOKUP_CODES;

	PROCEDURE InitializeDisplay(p_display_type VARCHAR2)
	IS
	BEGIN
		IF p_display_type = gc_HTML THEN
	        htp.p(htf.htmlOpen);
	        htp.p(htf.title(GetMsgTxt('XNP_CVU_REPORT')));
	        htp.p(htf.header(nsize=>2,
				cheader=>GetMsgTxt('XNP_CVU_REPORT'), calign=>'center'));
			htp.p(htf.bodyOpen);
			htp.p(htf.nl);
			htp.p(htf.nl);
		END IF;
    EXCEPTION
        WHEN OTHERS THEN
            HandleError('IniTializeDisplay', SQLCODE, SQLERRM);
	END InitializeDisplay;




	PROCEDURE CloseDisplay(p_display_type VARCHAR2)
	IS
	BEGIN
		IF p_display_type = gc_HTML THEN
			htp.p(htf.nl);
			htp.p(htf.nl);
	        htp.p(htf.header(nsize=>2, cheader=>GetMsgTxt('XNP_END_OF_REPORT'),
					 calign=>'center'));
			htp.p(htf.line);
			htp.p(htf.bodyClose);
        	htp.p(htf.htmlClose);
		END IF;
    EXCEPTION
        WHEN OTHERS THEN
            HandleError('CloseDisplay', SQLCODE, SQLERRM);
	END CloseDisplay;

	PROCEDURE StartCategory(p_error_code VARCHAR2)
	IS
	BEGIN
		Print(GetMsgTxt(p_error_code), gc_OK, gc_HEADER);
       g_category_no_error := TRUE;
    EXCEPTION
        WHEN OTHERS THEN
            HandleError('StartCategory', SQLCODE, SQLERRM);
	END StartCategory;

	PROCEDURE EndCategory
	IS
	BEGIN
		IF g_category_no_error THEN
			Print(GetMsgTxt('XNP_NO_ERROR_OR_WARNING'), gc_OK, gc_SUB_CONTEXT);
		END IF;
    EXCEPTION
        WHEN OTHERS THEN
            HandleError('EndCategory', SQLCODE, SQLERRM);
	END EndCategory;

    PROCEDURE STARTUP
    IS
    BEGIN


		InitializeDisplay(g_display_type);


		StartCategory('XNP_CVU_STATUS_TYPE_VALDNS');
        INITIAL_STATUS_OF_SV;
        LOCAL_SP_NAME;
        PHASE_IND_NO_STAT_TYPE;
		EndCategory;

		StartCategory('XNP_CVU_GEO_VALDNS');
        SINGLE_GEO_TREE;
		EndCategory;

		StartCategory('XNP_CVU_FAS_VALDNS');
        FULFILL_ACTIONS;
		EndCategory;

		StartCategory('XNP_CVU_FE_VALDNS');
        FULFILL_ELEMENT_VALIDITY;
        FULFILL_ELEMENT_REFERENCES;
        NEW_ADAPTER_TYPES;
		EndCategory;

		StartCategory('XNP_CVU_SP_VALDNS');
        SERVICE_PROVIDERS;
		EndCategory;

		StartCategory('XNP_CVU_NUMBER_VALDNS');
        NUM_RANGE_GEO_AREA;
        INVALID_NUMBER_RANGES;
        POOLED_NUMBER_RANGES;
        NON_PORTED_PORTABLE_NUM_RANGES;
        SERVED_NUMBER_RANGES;
        ENABLE_NRC;
		EndCategory;


		StartCategory('XNP_CVU_SERVICE_VALDNS');
        SERVICE_VALIDATIONS;
		EndCategory;

		StartCategory('XNP_CVU_PACKAGE_VALDNS');
        PACKAGE_VALIDATIONS;
		EndCategory;

		StartCategory('XNP_CVU_MSG_VALDNS');
        ACTIVITY_BASED_TIMERS;
        MESSAGE_COMPILATION;
		EndCategory;

		StartCategory('XNP_CVU_WI_VALDNS');
        WORK_ITEMS;
		EndCategory;

		StartCategory('XNP_CVU_FP_VALDNS');
		INVALID_FP;
		EndCategory;


		StartCategory('XNP_CVU_WF_VALDNS');
        -- For Cross validations only verbose report make sense
        WF_PP_MSG_CROSS_VALIDATION;
        WF_NO_RQD_ITEM_ATT;
		WF_SPECIAL_ACTIVITIES;
        SUBSCRIBE_TO_BUSINESS_EVENTS;
        SUBSCRIBE_TO_ACKS;
        WF_LOOKUP_CODES;
		EndCategory;


	    CloseDisplay(g_display_type);


    EXCEPTION
        WHEN OTHERS THEN
            HandleError('STARTUP', SQLCODE, SQLERRM);
    END STARTUP;
END XNP_CVU_PKG;

/
