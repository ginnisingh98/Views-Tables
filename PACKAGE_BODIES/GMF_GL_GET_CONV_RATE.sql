--------------------------------------------------------
--  DDL for Package Body GMF_GL_GET_CONV_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_GL_GET_CONV_RATE" AS
/* $Header: gmfcnvrb.pls 115.0 99/07/16 04:15:37 porting shi $ */
	CURSOR C_get_sob_curr ( porg_id	in NUMBER) IS
		SELECT ars.set_of_books_id,
			sob.currency_code
		FROM   ar_system_parameters_all ars,
			gl_sets_of_books sob
		WHERE
			NVL(ars.org_id,0)=NVL(porg_id, NVL(ars.org_id,0));

	CURSOR C_get_conv_type  IS
		SELECT conversion_type
		FROM   gl_daily_conversion_types types,
			gl_srce_mst gmtype
		WHERE
			gmtype.rate_type_code = types.user_conversion_type
			AND   gmtype.trans_source_code = 'OP';

  FUNCTION get_conv_rate (cur_code VARCHAR2, porg_id NUMBER) RETURN NUMBER IS
    conv_rate  NUMBER;
    conv_date  DATE;
    frm_cur_code  VARCHAR2(15);
    to_cur_code  VARCHAR2(15);
    set_of_books_id number;
    conv_type varchar2(30);
  BEGIN

    OPEN C_get_sob_curr (porg_id);
    FETCH C_get_sob_curr INTO
	set_of_books_id,
        to_cur_code;
    CLOSE C_get_sob_curr;

    OPEN C_get_conv_type;
    FETCH C_get_conv_type INTO conv_type;
    CLOSE C_get_conv_type;

    conv_date := sysdate;
    conv_rate := gl_currency_api.get_closest_rate (set_of_books_id, cur_code,
		conv_date, conv_type, 1000);

    return (conv_rate);

  EXCEPTION
    WHEN others THEN
      conv_rate := -1;
	-- DBMS_OUTPUT.PUT_LINE('SQL_CODE in GLCONVRT- ' || SQLCODE|| SQLERRM);
      RETURN (conv_rate);
  END;

END GMF_GL_GET_CONV_RATE;

/
