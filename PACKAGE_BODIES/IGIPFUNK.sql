--------------------------------------------------------
--  DDL for Package Body IGIPFUNK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIPFUNK" AS
-- $Header: igiexpab.pls 115.11 2003/08/09 11:36:03 rgopalan ship $
Procedure exp_num(ep_num    IN  IGI_exp_numbering_all.EP_NUMBERING_CODE%type,
                 doc_class  IN  IGI_exp_numbering_all.DOCUMENT_CLASS_CODE%type,
                 doc_type   IN  IGI_exp_numbering_all.DOCUMENT_TYPE_CODE%type,
                 trx_type   IN  IGI_exp_numbering_all.TRX_TYPE_CODE%type,
                 p_exp_num  out NOCOPY varchar2) AS
begin
null;
END exp_num;

Procedure insert_new_exp_row(l_ep_num IN Varchar2,
                             l_doc_class IN Varchar2,
                             l_doc_type IN Varchar2,
                             l_trx_type IN Varchar2,
                             pPrefix IN Varchar2,
                             PSuffix IN Varchar2,
                             b_fy IN Number,
                             l_app IN varchar2,
                             ep_num IN Varchar2,
                             doc_class IN Varchar2,
                             doc_type IN Varchar2,
                             trx_type IN varchar2,
                             p_num_id OUT NOCOPY number) is



BEGIN
null;
END insert_new_exp_row;

PROCEDURE create_trx(pnumber_id in number,
                     pPrefix in out NOCOPY varchar2,
                     pSuffix in out NOCOPY varchar2,
                     pnext_seq_val in out NOCOPY number,
                     pGL_date in date,
                     p_fy in number,
                     l_app in varchar2) is
BEGIN
null;
END create_trx;

PROCEDURE get_fiscal_year(aGl_date date, v_fy in out NOCOPY number) AS
BEGIN
null;
END get_fiscal_year;


PROCEDURE cancel_trx(gPrefix IN Varchar2,
                     gSeq_Num IN NUMBER,
                     gSuffix IN Varchar2
                     ) IS

BEGIN
 NULL;
END cancel_trx;

  Procedure ins_del(v_number_id in NUMBER,
                  vPrefix in varchar2,
                  vSuffix in varchar2,
                  vseq_num in number,
                  v_trx_date in date,
                  v_fy in number,
                  c_date in date,
                  l_app in varchar2) is
BEGIN
NULL;
END ins_del;

PROCEDURE redo_trx(pnumber_id in number,
                   pPrefix in out NOCOPY varchar2,
                   pSuffix in out NOCOPY varchar2,
                   pseq_val in out NOCOPY number,
                   pGL_date in date,
                   p_fy in number,
                   l_app in varchar2,
                   p_exp_num  in out NOCOPY varchar2) is

BEGIN
NULL;
END redo_trx;



END IGIPFUNK;

/
