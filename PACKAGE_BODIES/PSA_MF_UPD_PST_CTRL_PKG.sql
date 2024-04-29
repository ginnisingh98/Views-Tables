--------------------------------------------------------
--  DDL for Package Body PSA_MF_UPD_PST_CTRL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_MF_UPD_PST_CTRL_PKG" 
/* $Header: PSAMFUPB.pls 120.4 2006/09/13 14:03:55 agovil ship $ */
as


procedure update_posting_control(errbuf out NOCOPY varchar2, retcode out NOCOPY varchar2,
                                 p_posting_control_id in number)
is
  l_gl_posted_date date;
begin

  select gl_posted_date
  into l_gl_posted_date
  from ar_posting_control
  where posting_control_id = p_posting_control_id;

  update ra_cust_trx_line_gl_dist
  set gl_posted_date = l_gl_posted_date,
      posting_control_id= p_posting_control_id,
      last_update_date = sysdate
  where customer_trx_id  in (select customer_trx_id
			    from psa_mf_trx_rec_buf
			    where pst_ctrl_id = p_posting_control_id);

  update ar_receivable_applications
  set gl_posted_date = l_gl_posted_date,
      posting_control_id= p_posting_control_id,
      last_update_date = sysdate
  where receivable_application_id in (select ra_receivable_application_id
				      from psa_mf_rct_rec_buf
			              where pst_ctrl_id = p_posting_control_id);

  update ar_adjustments
  set gl_posted_date = l_gl_posted_date,
      posting_control_id= p_posting_control_id,
      last_update_date = sysdate
  where adjustment_id in (select adjustment_id
			  from psa_mf_adj_rec_buf
			  where pst_ctrl_id = p_posting_control_id);


            delete from psa_mf_trx_rec_buf
            where last_update_date + 2 < sysdate;

            delete from psa_mf_rct_rec_buf
            where last_update_date + 2 < sysdate;

            delete from psa_mf_adj_rec_buf
            where last_update_date + 2 < sysdate;

  commit;
end update_posting_control;

end PSA_MF_UPD_PST_CTRL_PKG;

/
