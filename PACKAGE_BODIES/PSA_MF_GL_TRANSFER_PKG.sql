--------------------------------------------------------
--  DDL for Package Body PSA_MF_GL_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_MF_GL_TRANSFER_PKG" AS
/* $Header: PSAMFGLB.pls 120.3 2006/09/13 12:54:44 agovil ship $ */

/**********************************/
/******* Transactions Body ********/
/**********************************/


FUNCTION psa_mf_trx_transfer(p_trx_rec in PSA_MFAR_UTILS.trx_rec)
RETURN varchar2
IS
	  ret_val 	varchar2(15) ;
	  errbuf 	varchar2(15);
	  retcode 	varchar2(15);
	  run_num 	number;
	  ret2 		varchar2(15);
BEGIN
	ret2 := psa_mf_MFAR_trx_jes(p_trx_rec);

	update psa_mf_trx_dist_all
           set posting_control_id = p_trx_rec.pst_ctrl_id
         where cust_trx_line_gl_dist_id in (select cust_trx_line_gl_dist_id
					      from ra_cust_trx_line_gl_dist
					     where customer_trx_id = p_trx_rec.customer_trx_id);

  RETURN ret_val;
END psa_mf_trx_transfer;


/**********************************/
/******* Adjustments Body ********/
/**********************************/
FUNCTION psa_mf_adj_transFer(p_adj_rec in PSA_MFAR_UTILS.adj_rec)
RETURN varchar2
IS
	  ret_val 	varchar2(15) ;
	  ret2 		varchar2(15);

BEGIN
	ret2 := psa_mf_MFAR_adj_jes(p_adj_rec);

	update psa_mf_adj_dist_all
           set posting_control_id = p_adj_rec.pst_ctrl_id
         where adjustment_id = p_adj_rec.adjustment_id;

  RETURN ret_val;
END psa_mf_adj_transfer;


/**********************************/
/******* Receipts Body ********/
/**********************************/
FUNCTION psa_mf_rct_transfer(p_rct_rec in PSA_MFAR_UTILS.rct_rec)
RETURN varchar2
IS
  ret_val varchar2(15) ;
  ret2 varchar2(15);

BEGIN
	ret2 := psa_mf_MFAR_rct_jes(p_rct_rec);

	update psa_mf_rct_dist_all
           set posting_control_id        = p_rct_rec.pst_ctrl_id
         where receivable_application_id = p_rct_rec.ra_receivable_application_id;

  RETURN ret_val;
END psa_mf_rct_transfer;

/******************************************************/
/* Function to Insert TRX additionalMFAR jes into GL Interface */
/******************************************************/
FUNCTION psa_mf_MFAR_trx_jes(p_trx_rec in PSA_MFAR_UTILS.trx_rec)
return varchar2
IS
BEGIN
RETURN 'TRUE';
END psa_mf_MFAR_trx_jes;

/******************************************************/
/* Function to Insert ADJ additionalMFAR jes into GL Interface */
/******************************************************/
FUNCTION psa_mf_MFAR_adj_jes(p_adj_rec in PSA_MFAR_UTILS.adj_rec)
RETURN varchar2
IS
BEGIN
RETURN 'TRUE';
END psa_mf_MFAR_adj_jes;

/*****************************************************/
/* Function to Insert RCT additionalMFAR jes into GL Interface */
/*****************************************************/
FUNCTION psa_mf_MFAR_rct_jes(p_rct_rec in PSA_MFAR_UTILS.rct_rec)
RETURN varchar2
IS
BEGIN
  RETURN 'TRUE';
END psa_mf_MFAR_rct_jes;


function get_entered_dr_rct (p_lookup_code in number, p_amount in number,
                        p_discount in number,
                        p_ue_discount in number)
return number
is
 the_amount number;
begin
  if p_lookup_code in (1,2,3,4) then
   the_amount := p_amount;
  elsif p_lookup_code in (5,6,7,8) then
   the_amount := p_discount;
  elsif p_lookup_code in (9,10,11,12) then
   the_amount := p_ue_discount;
  end if;
  if (the_amount >= 0)  then -- positive
    if p_lookup_code in (2,4,6,8,10,12) then --Even (Cr) Lines
     the_amount := NULL;
    end if;
  elsif (the_amount < 0)  then -- negative
    if p_lookup_code in (1,3,5,7,9,11)  then -- Odd (Dr) Lines
     the_amount := NULL;
    elsif p_lookup_code in (2,4,6,8,10,12) then --Even (Cr) Lines
     the_amount := -1 * the_amount ;
    end if;
  end if;
  return the_amount;
end;


function get_entered_cr_rct (p_lookup_code in number, p_amount in number,
                        p_discount in number,
                        p_ue_discount in number)
return number
is
  the_amount number;
begin
  if p_lookup_code in (1,2,3,4) then
    the_amount := p_amount;
  elsif p_lookup_code in (5,6,7,8) then
    the_amount := p_discount;
  elsif p_lookup_code in (9,10,11,12) then
    the_amount := p_ue_discount;
  end if;
  if (the_amount >= 0) then -- positive
    if p_lookup_code in (1,3,5,7,9,11) then --Odd (Dr) Lines
      the_amount := NULL;
    end if;
  elsif (the_amount < 0)  then -- negative
    if p_lookup_code in (2,4,6,8,10,12)  then -- Even (Cr)  Lines
      the_amount := NULL;
    elsif p_lookup_code in (1,3,5,7,9,11) then --Odd (Dr) Lines
      the_amount := -1 * the_amount ;
    end if;
  end if;
  return the_amount;
end;


function get_entered_dr_adj (p_lookup_code in number, p_amount in number)
return number
is
 the_amount number;
begin
  the_amount := p_amount;
  if (the_amount < 0)  then -- negative
    if p_lookup_code in (1,3) then --Odd (Dr) Lines
     the_amount := -1 * the_amount ;
    elsif p_lookup_code in (2,4) then --Even (Cr) Lines
     the_amount := NULL;
    end if;
  elsif (the_amount >= 0)  then -- positive
    if p_lookup_code in (1,3)  then -- Odd (Dr) Lines
     the_amount := NULL;
    end if;
  end if;
  return the_amount;
end;


function get_entered_cr_adj (p_lookup_code in number, p_amount in number)
return number
is
  the_amount number;
begin
    the_amount := p_amount;
  if (the_amount < 0) then -- negative
    if p_lookup_code in (1,3) then --Odd (Dr) Lines
      the_amount := NULL;
    elsif p_lookup_code in (2,4) then --Even (Cr) Lines
      the_amount := -1 * the_amount ;
    end if;
  elsif (the_amount >= 0)  then -- positive
    if p_lookup_code in (2,4)  then -- Even (Cr)  Lines
      the_amount := NULL;
    end if;
  end if;
  return the_amount;
end;



function get_entered_cr_crm (p_lookup_code in number, p_amount in number)
return number
is
  the_amount number := NULL;
begin
  if p_lookup_code in (1)  then
    the_amount := p_amount * -1;
  end if;
  return the_amount;
end;

function get_entered_dr_crm (p_lookup_code in number, p_amount in number)
return number
is
 the_amount number := NULL;
begin
  if p_lookup_code in (2)  then
    the_amount := p_amount * -1;
  end if;
  return the_amount;
end;

END PSA_MF_GL_TRANSFER_PKG;

/
