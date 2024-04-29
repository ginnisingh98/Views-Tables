--------------------------------------------------------
--  DDL for Package Body BSC_PORTLET_KPILISTCUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_PORTLET_KPILISTCUST" as
/* $Header: BSCPKCB.pls 120.4 2007/02/08 14:11:56 ppandey ship $ */

/* Customization table
ICX_PORTLET_CUSTOMIZATIONS -- This will be available for anyone to use
 REFERENCE_PATH                  NOT NULL VARCHAR2(100)
 PLUG_ID                                  NUMBER -- Not use in this portlet
 APPLICATION_ID                           NUMBER
 RESPONSIBILITY_ID                        NUMBER
 SECURITY_GROUP_ID                        NUMBER
 CACHING_KEY                              VARCHAR2(55)
 TITLE                                    VARCHAR2(100)

*/




------------------------------------------------------------------
-- juwang's code goes from here
------------------------------------------------------------------


--==========================================================================+
--    PROCEDURE
--       get_pluginfo_params
--
--    PURPOSE
--       This procedure builds the paramters list.
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================
FUNCTION get_pluginfo_params(
    p_resp_id IN NUMBER) RETURN VARCHAR2 IS


    l_ext_params VARCHAR2(100):= NULL;


BEGIN

    l_ext_params := bsc_portlet_util.PR_RESPID || '=' || p_resp_id;
    RETURN l_ext_params;



END get_pluginfo_params;









--==========================================================================+
--    PROCEDURE
--       get_resp_id
--
--    PURPOSE
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================
/*
FUNCTION get_resp_id(
    p_session_id IN pls_integer,
    p_plug_id    IN pls_integer) RETURN NUMBER IS

    l_resp_id NUMBER := bsc_portlet_util.VALUE_NOT_SET;

    CURSOR c_kg_p IS
        SELECT p.RESPONSIBILITY_ID
        FROM icx_portlet_customizations p
        WHERE
	    p.PLUG_ID = p_plug_id;


BEGIN

    IF icx_sec.validateSessionPrivate(p_session_id) THEN

  	OPEN c_kg_p;
      	FETCH c_kg_p INTO l_resp_id;

        CLOSE c_kg_p;

    END IF; -- icx_sec.validateSessionPrivate(p_session_id)

    RETURN l_resp_id;
END get_resp_id;
*/


--==========================================================================+
--    PROCEDURE
--       insert_row
--
--    PURPOSE
--        This procedure is used internally.  It is used to insert
--        table: BSC_USER_KPILIST_PLUGS
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================

PROCEDURE insert_row (
    p_plug_id IN NUMBER,
    p_details_flag IN NUMBER,
    p_group_flag IN NUMBER,
    p_kpi_measure_details_flag IN NUMBER,
    p_last_update_date IN DATE,
    p_last_updated_by IN NUMBER
) IS
    insert_err  EXCEPTION;
BEGIN
    INSERT INTO BSC_USER_KPILIST_PLUGS (
	PLUG_ID,
	DETAILS_FLAG,
	GROUP_FLAG,
        KPI_MEASURE_DETAILS_FLAG,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
    ) VALUES (
	p_plug_id,
	p_details_flag,
	p_group_flag,
        p_kpi_measure_details_flag,
	p_last_update_date,
	p_last_updated_by,
	p_last_update_date,
	p_last_updated_by,
	p_last_updated_by
    );

    IF SQL%ROWCOUNT = 0 THEN
       RAISE insert_err;
    END IF;

END insert_row;


--==========================================================================+
--    PROCEDURE
--       insert_row - signature with "p_reference_path IN VARCHAR2"
--
--    PURPOSE
--        This procedure is used internally.  It is used to insert
--        table: BSC_USER_KPILIST_PLUGS
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2003 Aditya Created.
--==========================================================================

PROCEDURE insert_row (
    p_plug_id IN NUMBER,
    p_reference_path IN VARCHAR2,
    p_details_flag IN NUMBER,
    p_group_flag IN NUMBER,
    p_kpi_measure_details_flag IN NUMBER,
    p_last_update_date IN DATE,
    p_last_updated_by IN NUMBER
) IS
    insert_err  EXCEPTION;
BEGIN
    INSERT INTO BSC_USER_KPILIST_PLUGS (
	PLUG_ID,
	DETAILS_FLAG,
	GROUP_FLAG,
        KPI_MEASURE_DETAILS_FLAG,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	REFERENCE_PATH
    ) VALUES (
	p_plug_id,
	p_details_flag,
	p_group_flag,
	p_kpi_measure_details_flag,
	p_last_update_date,
	p_last_updated_by,
	p_last_update_date,
	p_last_updated_by,
	p_last_updated_by,
	p_reference_path
    );

    IF SQL%ROWCOUNT = 0 THEN
       RAISE insert_err;
    END IF;

END insert_row;



--==========================================================================+
--    PROCEDURE
--       update_row
--
--    PURPOSE
--        This procedure is used internally.  It is used to update
--        table: BSC_USER_KPILIST_PLUGS
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================

PROCEDURE update_row (
    p_plug_id IN NUMBER,
    p_details_flag IN NUMBER,
    p_group_flag IN NUMBER,
    p_kpi_measure_details_flag IN NUMBER,
    p_last_update_date IN DATE,
    p_last_updated_by IN NUMBER
) IS

    update_err  EXCEPTION;
BEGIN
	UPDATE
	    BSC_USER_KPILIST_PLUGS
  	SET
	    DETAILS_FLAG = p_details_flag,
	    GROUP_FLAG = p_group_flag,
            KPI_MEASURE_DETAILS_FLAG = p_kpi_measure_details_flag,
	    LAST_UPDATE_DATE = SYSDATE,
	    LAST_UPDATED_BY = p_last_updated_by,
	    LAST_UPDATE_LOGIN = p_last_updated_by
	WHERE
	    PLUG_ID = p_plug_id;

        IF SQL%ROWCOUNT = 0 THEN
              RAISE update_err;
        END IF;
END update_row;

--==========================================================================+
--    PROCEDURE
--       update_row - updated with reference path
--
--    PURPOSE
--        This procedure is used internally.  It is used to update
--        table: BSC_USER_KPILIST_PLUGS
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2003 Aditya Created with a new signature.
--==========================================================================

PROCEDURE update_row (
    p_plug_id IN NUMBER,
    p_reference_path IN VARCHAR2,
    p_details_flag IN NUMBER,
    p_group_flag IN NUMBER,
    p_kpi_measure_details_flag IN NUMBER,
    p_last_update_date IN DATE,
    p_last_updated_by IN NUMBER
) IS

    update_err  EXCEPTION;
BEGIN
	UPDATE
	    BSC_USER_KPILIST_PLUGS
  	SET
	    DETAILS_FLAG = p_details_flag,
	    GROUP_FLAG = p_group_flag,
	    KPI_MEASURE_DETAILS_FLAG = p_kpi_measure_details_flag,
	    LAST_UPDATE_DATE = SYSDATE,
	    LAST_UPDATED_BY = p_last_updated_by,
	    LAST_UPDATE_LOGIN = p_last_updated_by
	WHERE
	    PLUG_ID = p_plug_id
    AND REFERENCE_PATH = p_reference_path;

        IF SQL%ROWCOUNT = 0 THEN
              RAISE update_err;
        END IF;
END update_row;



--==========================================================================+
--    PROCEDURE
--       update_icx_portlet_cust - changed signature for reference_path
--
--    PURPOSE
--        This procedure is used internally.  It is used to update
--        table: ICX_PORTLET_CUSTOMIZATIONS
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2003 Aditya Created.
--==========================================================================

PROCEDURE update_icx_portlet_cust (
    p_plug_id IN NUMBER,
    p_reference_path IN VARCHAR2,
    p_resp_id IN NUMBER,
    p_portlet_name IN VARCHAR
) IS

    update_err  EXCEPTION;
BEGIN
	 -- Added by Aditya for bug #2891539
	 -- Remove cacheing everytime the portlet is cust.

	UPDATE
	    ICX_PORTLET_CUSTOMIZATIONS
  	SET
	    CACHING_KEY        = TO_CHAR(TO_NUMBER(NVL(caching_key, 0))+1)
	  , RESPONSIBILITY_ID  = p_resp_id
	  , TITLE              = p_portlet_name
	  , PLUG_ID            = p_plug_id
	WHERE
	    REFERENCE_PATH = p_reference_path;

	IF SQL%ROWCOUNT = 0 THEN
              RAISE update_err;
        END IF;
END update_icx_portlet_cust;

--==========================================================================+
--    PROCEDURE
--       update_icx_portlet_cust
--
--    PURPOSE
--        This procedure is used internally.  It is used to update
--        table: ICX_PORTLET_CUSTOMIZATIONS
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================

PROCEDURE update_indicators (
    p_resp_id IN NUMBER,
    p_last_update_date IN DATE,
    p_last_updated_by IN NUMBER,
    p_number_array IN BSC_NUM_LIST
) IS

    l_kpi_id Number;
    l_paramlist_id Number;


    CURSOR c IS
	SELECT BK.INDICATOR
	FROM
	BSC_KPIS_B BK,
	BSC_TAB_INDICATORS BTI,
	BSC_USER_TAB_ACCESS BTA,
	BSC_USER_KPI_ACCESS BA
	WHERE
	BA.RESPONSIBILITY_ID = p_resp_id AND
	BA.INDICATOR IN (
            SELECT
                t.COLUMN_VALUE
	    FROM TABLE(CAST(p_number_array AS BSC_NUM_LIST)) t) AND
	BA.INDICATOR = BK.INDICATOR AND
	BTI.INDICATOR = BK.INDICATOR AND
	BTA.TAB_ID = BTI.TAB_ID AND
	BTA.RESPONSIBILITY_ID = BA.RESPONSIBILITY_ID AND
	SYSDATE BETWEEN NVL(BTA.START_DATE(+), SYSDATE) AND
	NVL(BTA.END_DATE(+), SYSDATE) AND
	BK.PROTOTYPE_FLAG <> 2  AND
	not exists (
	SELECT BUP.INDICATOR
	FROM BSC_USER_PARAMETERS_B BUP
	WHERE BUP.INDICATOR = BA.INDICATOR AND
	BUP. VIEW_TYPE = 1
	)
	ORDER BY BK.INDICATOR;



BEGIN


    OPEN c;
    LOOP
	FETCH c INTO l_kpi_id;
	EXIT WHEN c%NOTFOUND;
	BSC_USER_PARAMETERS_PKG.INSERT_ROW(l_paramlist_id,
	NULL,
	BSC_PORTLET_KPILISTCUST.APPLICATION_ID,
	l_kpi_id,
	1,1,
 	NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,
 	NULL,NULL,NULL,NULL,NULL,
	p_last_update_date,
	p_last_updated_by,
	p_last_update_date,
	p_last_updated_by,
	p_last_updated_by);
	-- dbms_output.put_line('kpi =' || TO_CHAR(l_kpi_id));
    END LOOP;
    CLOSE c;
END update_indicators;



--==========================================================================+
--    PROCEDURE
--       insert_param_id
--
--    PURPOSE
--        This procedure is used internally.  It is used to update
--        table: ICX_PORTLET_CUSTOMIZATIONS
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================

PROCEDURE insert_param_id(
    p_plug_id IN NUMBER,
    p_resp_id IN NUMBER,
    p_last_update_date IN DATE,
    p_last_updated_by IN NUMBER,
    p_number_array IN BSC_NUM_LIST
) IS



BEGIN

    DELETE from bsc_user_kpilist_kpis
    WHERE plug_id = p_plug_id;

    INSERT INTO bsc_user_kpilist_kpis (
	PLUG_ID,
	PARAM_LIST_ID,
 	CREATION_DATE,
	CREATED_BY,
 	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
    ) SELECT
	p_plug_id,
	bup.PARAM_LIST_ID,
   	p_last_update_date,
    	p_last_updated_by,
   	p_last_update_date,
    	p_last_updated_by,
    	p_last_updated_by
    FROM bsc_user_parameters_b bup,
	 BSC_KPIS_B BK,
	 BSC_TAB_INDICATORS BTI,
	 BSC_USER_TAB_ACCESS BTA,
	 BSC_USER_KPI_ACCESS BA
    WHERE
	BA.RESPONSIBILITY_ID = p_resp_id AND
	BA.INDICATOR IN (
            SELECT
                t.COLUMN_VALUE
	    FROM TABLE(CAST(p_number_array AS BSC_NUM_LIST)) t) AND
	BA.INDICATOR = BK.INDICATOR AND
	BTI.INDICATOR = BK.INDICATOR AND
	BTA.TAB_ID = BTI.TAB_ID AND
	BTA.RESPONSIBILITY_ID = BA.RESPONSIBILITY_ID AND
	SYSDATE BETWEEN NVL(BTA.START_DATE(+), SYSDATE) AND
	NVL(BTA.END_DATE(+), SYSDATE) AND
	BK.PROTOTYPE_FLAG <> 2 AND
	bup.INDICATOR = bk.INDICATOR AND
        bup. VIEW_TYPE = 1;

--        bup.PARAM_LIST_ID NOT IN (
--	    SELECT ek.PARAM_LIST_ID
--   	    FROM bsc_user_kpilist_kpis ek
--	    WHERE ek.plug_id = p_plug_id
--        );
END insert_param_id;





--==========================================================================+
--    PROCEDURE
--       set_customized_data_private_n -Signature changed by Aditya
--
--    PURPOSE
--       This functions is use internally for Web Provider KpiList Portlet
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2003 Aditya Created. - Modified the signature
--==========================================================================
FUNCTION set_customized_data_private_n(
    p_user_id IN NUMBER,
    p_plug_id IN NUMBER,
    p_reference_path IN VARCHAR2,
    p_resp_id IN NUMBER,
    p_details_flag IN NUMBER,
    p_group_flag IN NUMBER,
    p_kpi_measure_details_flag IN NUMBER,
    p_createy_by IN NUMBER,
    p_last_updated_by IN NUMBER,
    p_porlet_name IN VARCHAR2,
    p_number_array IN BSC_NUM_LIST,
    p_o_ret_status OUT NOCOPY NUMBER) RETURN VARCHAR2 IS

    insert_err  EXCEPTION;
    update_err  EXCEPTION;

    l_errmesg VARCHAR2(2000) := bsc_portlet_util.MSGTXT_SUCCESS;
    l_count NUMBER := 0;

BEGIN
     SELECT count(*)
     INTO   l_count
     FROM   BSC_USER_KPILIST_PLUGS k
     WHERE
	 k.PLUG_ID = p_plug_id;

     --DBMS_OUTPUT.PUT_LINE('set_cust_n');
     --DBMS_OUTPUT.PUT_LINE('l_count-->'||l_count);

    ---------------------------------
    -- update bsc_user_kpilist_plugs
    ---------------------------------
    IF (l_count > 0) THEN  -- record exists, need to update
	update_row(p_plug_id, p_reference_path ,p_details_flag, p_group_flag, p_kpi_measure_details_flag, sysdate, p_last_updated_by);
    ELSE -- record does not exist, insert it
	insert_row(p_plug_id, p_reference_path, p_details_flag, p_group_flag, p_kpi_measure_details_flag, sysdate, p_last_updated_by);
    END IF;  -- (l_count > 0)

    -------------------------------------
    -- update ICX_PORTLET_CUSTOMIZATIONS
    -------------------------------------
    --DBMS_OUTPUT.PUT_LINE('update_icx_portlet_cust');
    update_icx_portlet_cust(p_plug_id, p_reference_path, p_resp_id, p_porlet_name);
    --DBMS_OUTPUT.PUT_LINE('update_indicators');
    update_indicators(p_resp_id, sysdate, p_last_updated_by, p_number_array);
    --DBMS_OUTPUT.PUT_LINE('insert_param_id');
    insert_param_id(p_plug_id, p_resp_id, sysdate, p_last_updated_by, p_number_array);


    -- everything works ok so we commit
    COMMIT;
    p_o_ret_status := bsc_portlet_util.CODE_RET_SUCCESS;
    RETURN bsc_portlet_util.MSGTXT_SUCCESS;

EXCEPTION

    WHEN insert_err THEN
        ROLLBACK;
        p_o_ret_status := bsc_portlet_util.CODE_RET_ERROR;
        l_errmesg := 'Error inserting to BSC_USER_KPILIST_PLUGS';
	RETURN l_errmesg;


    WHEN update_err THEN
        ROLLBACK;
        p_o_ret_status := bsc_portlet_util.CODE_RET_ERROR;
        l_errmesg := 'Error updating to BSC_USER_KPILIST_PLUGS';
	RETURN l_errmesg;

    WHEN OTHERS THEN
        ROLLBACK;
        p_o_ret_status := bsc_portlet_util.CODE_RET_ERROR;
	l_errmesg :=  'Error in bsc_portlet_graph.set_customized_data_private. SQLERRM = ' || SQLERRM;
	RETURN l_errmesg;



END set_customized_data_private_n;



--==========================================================================+
--    FUNCTION
--       get_customization
--
--    PURPOSE
--       This function is used by
--       oracle.apps.bsc.iviewer.thinext.client.OPortalDataExtractor
--       class.
--    PARAMETERS
--       p_has_selected_kpi : 1=>TRUE, 0->FALSE
--    HISTORY
--       08-MAR-2001 juwang Created.

--==========================================================================
FUNCTION get_customization(
    p_cookie_value IN VARCHAR2,
    p_encrypted_plug_id IN VARCHAR2,
    p_portlet_id IN NUMBER,
    p_resp_id OUT NOCOPY NUMBER,
    p_plug_id OUT NOCOPY NUMBER,
    p_user_id OUT NOCOPY NUMBER,
    p_details_flag OUT NOCOPY NUMBER,
    p_group_flag OUT NOCOPY NUMBER,
    p_display_name OUT NOCOPY VARCHAR2,
    p_has_selected_kpi OUT NOCOPY NUMBER,
    p_kpi_measure_details_flag OUT NOCOPY NUMBER) RETURN NUMBER IS

    l_session_id NUMBER;
    l_num_sel_kpis NUMBER;

    -- bug fix 2072699

     CURSOR c_kg_p IS
        SELECT p.RESPONSIBILITY_ID, NVL(k.DETAILS_FLAG, 0), NVL(k.GROUP_FLAG, 0), p.TITLE, NVL(k.kpi_measure_details_flag, 0)
        FROM   bsc_user_kpilist_plugs k,
               icx_portlet_customizations p
        WHERE
	    p.PLUG_ID = p_plug_id AND
	    k.PLUG_ID(+)= p.PLUG_ID;


    CURSOR c_fm IS
	SELECT USER_FUNCTION_NAME
        FROM   FND_FORM_FUNCTIONS_VL
        WHERE  FUNCTION_ID = p_portlet_id;


BEGIN


    bsc_portlet_util.decrypt_plug_info(p_cookie_value,
	p_encrypted_plug_id, l_session_id, p_plug_id);


    IF icx_sec.validateSessionPrivate(l_session_id) THEN
        p_user_id := icx_sec.getID(icx_sec.PV_USER_ID,'', l_session_id);


        OPEN c_kg_p;
        FETCH c_kg_p INTO p_resp_id, p_details_flag, p_group_flag, p_display_name, p_kpi_measure_details_flag;

        IF c_kg_p%FOUND THEN  -- the record is found,


	    -- checks if  display name is null
	    IF (p_display_name IS NULL) THEN
		OPEN c_fm;
                FETCH c_fm INTO  p_display_name;
                CLOSE c_fm;
	    END IF; -- (p_display_name IS NULL)
	    CLOSE c_kg_p;

	    -- checks if there is any selected kpis
            SELECT COUNT(*) INTO l_num_sel_kpis
            FROM bsc_user_kpilist_kpis
            WHERE plug_id = p_plug_id;


            IF (l_num_sel_kpis = 0 ) THEN
		p_has_selected_kpi := 0;
	    ELSE
		p_has_selected_kpi := 1;
            END IF; --  (l_num_sel_kpis = 0 )
 	    RETURN bsc_portlet_util.CODE_RET_SUCCESS;

        ELSE  -- not found, no such plug i
   	    CLOSE c_kg_p;
	    RETURN bsc_portlet_util.CODE_RET_NOROW;

        END IF;  -- c_kg_p%FOUND

    ELSE  -- session expires
	RETURN bsc_portlet_util.CODE_RET_SESSION_EXP;
    END IF;  -- icx_sec.validateSessionPrivate(l_session_id)
EXCEPTION
  WHEN OTHERS THEN
    --close the open cursors if any.
    IF(c_kg_p%ISOPEN) THEN
      CLOSE c_kg_p;
    END IF;
    IF(c_fm%ISOPEN) THEN
      CLOSE c_fm;
    END IF;
END get_customization;




end BSC_PORTLET_KPILISTCUST;

/
