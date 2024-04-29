--------------------------------------------------------
--  DDL for Package Body JE_NO_VAT_RECON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_NO_VAT_RECON_PKG" as
/* $Header: jenovrcb.pls 120.3.12010000.2 2008/08/04 12:27:50 vgadde ship $ */

  -- Some common string constants.

  h_line        varchar2(4);
  h_offset      varchar2(6);
  h_ap          varchar2(2);
  h_ar          varchar2(2);
  h_gl          varchar2(2);

procedure update_ar1
	(p_bal_colname varchar2,
	 p_acc_colname varchar2
	) is
  TYPE update_ar1_type IS REF CURSOR;
  upd_ar1 update_ar1_type;
  sql_stmt		varchar2(2000);

  h_bal			varchar2(20);
  h_acc			varchar2(20);

  h_jg_info_v1		varchar2(150);
  h_jg_info_v2          varchar2(150);
  h_jg_info_v3          varchar2(150);
  h_jg_info_v4          varchar2(150);
  h_jg_info_v5          varchar2(150);
  h_jg_info_v6          varchar2(150);
  h_jg_info_v7          varchar2(150);
  h_jg_info_v8          varchar2(150);
  h_jg_info_v9          varchar2(150);
  h_jg_info_v10          varchar2(150);
  h_jg_info_v11          varchar2(150);
  h_jg_info_v12          varchar2(150);
  h_jg_info_n1		number;
  h_jg_info_n2          number;
  h_jg_info_n3          number;
  h_jg_info_n4          number;
  h_jg_info_n5          number;
  h_jg_info_n6          number;
  h_jg_info_n7          number;
  h_jg_info_n8          number;
  h_jg_info_n9          number;
  h_jg_info_n10          number;
  h_jg_info_n11          number;
  h_jg_info_n12          number;
  h_jg_info_n13          number;
  h_jg_info_n14          number;
  h_jg_info_n15          number;
  h_jg_info_d1		date;

  h_trxgl_acct_amt	number;

  h_trx_id_prev		number := -1;
  h_trx_line_num_prev   number := -1;

begin
  h_line    := 'LINE';
  h_offset  := 'OFFSET';
  h_ap      := 'AP';
  h_ar      := 'AR';
  h_gl      := 'GL';
  sql_stmt := 'select '||p_bal_colname||', '||p_acc_colname||
			', jgzz.jg_info_v1'||
			', jgzz.jg_info_v2'||
                        ', jgzz.jg_info_v3'||
                        ', jgzz.jg_info_v4'||
                        ', jgzz.jg_info_v5'||
                        ', jgzz.jg_info_v6'||
                        ', jgzz.jg_info_v7'||
                        ', jgzz.jg_info_v8'||
                        ', jgzz.jg_info_v9'||
                        ', jgzz.jg_info_v10'||
                        ', jgzz.jg_info_v11'||
                        ', jgzz.jg_info_v12'||
                        ', jgzz.jg_info_n1'||
                        ', jgzz.jg_info_n2'||
                        ', jgzz.jg_info_n3'||
                        ', jgzz.jg_info_n4'||
                        ', jgzz.jg_info_n5'||
                        ', jgzz.jg_info_n6'||
                        ', jgzz.jg_info_n7'||
                        ', jgzz.jg_info_n8'||
                        ', jgzz.jg_info_n9'||
                        ', jgzz.jg_info_n10'||
                        ', jgzz.jg_info_n11'||
                        ', jgzz.jg_info_n12'||
                        ', jgzz.jg_info_n13'||
                        ', jgzz.jg_info_n14'||
                        ', jgzz.jg_info_n15'||
			', jgzz.jg_info_d1'||
			', ca.acctd_amount'||
		' from  ra_customer_trx_lines_all ra,'||
                        'ra_cust_trx_line_gl_dist_all ca,'||
                        'jgzz_ar_tax_global_tmp jgzz,'||
                        'gl_code_combinations cc '||
                        'where ra.customer_trx_id=jgzz.jg_info_n1 '||
                        'and ra.line_number=jgzz.jg_info_n9 '||
                        'and ra.customer_trx_line_id=ca.customer_trx_line_id '||
                        'and ra.customer_trx_id=ca.customer_trx_id ' ||
                        'and ra.line_type= :line '||
                        'and cc.code_combination_id=ca.code_combination_id '||
                        'and jgzz.jg_info_v7 <> :offset '||
                        'and jgzz.jg_info_v2 = :ar';

  OPEN upd_ar1 FOR sql_stmt USING h_line, h_offset, h_ar;
  LOOP
         FETCH upd_ar1 INTO h_bal, h_acc,
		h_jg_info_v1,
                h_jg_info_v2,
                h_jg_info_v3,
                h_jg_info_v4,
		h_jg_info_v5,
                h_jg_info_v6,
                h_jg_info_v7,
                h_jg_info_v8,
                h_jg_info_v9,
                h_jg_info_v10,
		h_jg_info_v11,
                h_jg_info_v12,  -- gap
                h_jg_info_n1,
                h_jg_info_n2,
                h_jg_info_n3,
                h_jg_info_n4,
                h_jg_info_n5,
                h_jg_info_n6,
                h_jg_info_n7,
                h_jg_info_n8,
                h_jg_info_n9,
                h_jg_info_n10,
                h_jg_info_n11,
                h_jg_info_n12,
		h_jg_info_n13,
                h_jg_info_n14,
                h_jg_info_n15,  -- gap
                h_jg_info_d1,
		h_trxgl_acct_amt;
         EXIT WHEN upd_ar1%NOTFOUND;

	 h_jg_info_n4 := h_trxgl_acct_amt;

	 if ((h_jg_info_n1 = h_trx_id_prev) and (h_jg_info_n9 = h_trx_line_num_prev)) then
	    h_jg_info_n7 := 0;
	    h_jg_info_n13 := 0;
	 end if;

	 insert into jgzz_ar_tax_global_tmp (
		JG_INFO_V1,
		JG_INFO_V2,
		JG_INFO_V3,
		JG_INFO_V4,
		JG_INFO_V5,
		JG_INFO_V6,
		JG_INFO_V7,
		JG_INFO_V8,
		JG_INFO_V9,
		JG_INFO_V10,
		JG_INFO_V11,
		JG_INFO_V12,
		JG_INFO_V13,
		JG_INFO_V14,
		JG_INFO_V15,
		JG_INFO_N1,
                JG_INFO_N2,
                JG_INFO_N3,
                JG_INFO_N4,
                JG_INFO_N5,
                JG_INFO_N6,
                JG_INFO_N7,
                JG_INFO_N8,
                JG_INFO_N9,
                JG_INFO_N10,
                JG_INFO_N11,
                JG_INFO_N12,
                JG_INFO_N13,
                JG_INFO_N14,
                JG_INFO_N15,
		JG_INFO_D1,
                JG_INFO_D2,
                JG_INFO_D3,
                JG_INFO_D4,
                JG_INFO_D5,
                JG_INFO_D6,
                JG_INFO_D7,
                JG_INFO_D8,
                JG_INFO_D9,
                JG_INFO_D10,
                JG_INFO_D11,
                JG_INFO_D12,
                JG_INFO_D13,
                JG_INFO_D14,
                JG_INFO_D15 )
	 values (h_jg_info_v1,
		h_jg_info_v2,
		h_jg_info_v3,
		h_jg_info_v4,
                h_bal||'.'||h_acc, 	-- jg_info_v5, but no h_jg_info_v5
		h_jg_info_v6,
                h_jg_info_v7,
                h_jg_info_v8,
                h_jg_info_v9,
		h_jg_info_v10,
                h_jg_info_v11,
                h_jg_info_v12,
                NULL,                   -- jg_info_v13,
                NULL,                   -- jg_info_v14,
                NULL,                   -- jg_info_v15,
                h_jg_info_n1,
		h_jg_info_n2,
                h_jg_info_n3,
                h_jg_info_n4,
                h_jg_info_n5,
                h_jg_info_n6,
                h_jg_info_n7,
                h_jg_info_n8,
                h_jg_info_n9,
                h_jg_info_n10,
                h_jg_info_n11,
                h_jg_info_n12,
                h_jg_info_n13,
                h_jg_info_n14,
                h_jg_info_n15,
                h_jg_info_d1,
		NULL,			-- jg_info_d2,
                NULL, 			-- jg_info_d3,
                NULL,                   -- jg_info_d4,
                NULL,                   -- jg_info_d5,
                NULL,                   -- jg_info_d6,
                NULL,                   -- jg_info_d7,
                NULL,                   -- jg_info_d8,
                NULL,                   -- jg_info_d9,
                NULL,                   -- jg_info_d10,
                NULL,                   -- jg_info_d11,
                NULL,                   -- jg_info_d12,
                NULL,                   -- jg_info_d13,
                NULL,                   -- jg_info_d14,
                to_date('2049/12/31','YYYY/MM/DD')	-- jg_info_d15
		);

		h_trx_id_prev := h_jg_info_n1;
		h_trx_line_num_prev := h_jg_info_n9;

	END LOOP;
        CLOSE upd_ar1;

	delete from jgzz_ar_tax_global_tmp
	where  jg_info_v2 = 'AR'
	and    jg_info_v7 <> 'OFFSET'
        and    (jg_info_d15 is null
		or jg_info_d15 <> to_date('2049/12/31','YYYY/MM/DD'));

end;  -- Procedure update_ar1

end JE_NO_VAT_RECON_PKG;

/
