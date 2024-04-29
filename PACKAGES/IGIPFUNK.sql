--------------------------------------------------------
--  DDL for Package IGIPFUNK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIPFUNK" AUTHID CURRENT_USER as
-- $Header: igiexpas.pls 115.8 2002/11/18 06:31:18 sowsubra ship $
Procedure exp_num (ep_num    IN  igi_exp_numbering_all.EP_NUMBERING_CODE%type,
                 doc_class  IN  igi_exp_numbering_all.DOCUMENT_CLASS_CODE%type,
                 doc_type   IN  igi_exp_numbering_all.DOCUMENT_TYPE_CODE%type,
                 trx_type   IN  igi_exp_numbering_all.TRX_TYPE_CODE%type,
                 p_exp_num  out NOCOPY varchar2);

Procedure insert_new_exp_row (l_ep_num IN Varchar2,
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
                             p_num_id OUT NOCOPY number) ;

PROCEDURE create_trx(pnumber_id in number,
                     pPrefix in out NOCOPY varchar2,
                     pSuffix in out NOCOPY varchar2,
                     pnext_seq_val in out NOCOPY number,
                     pGL_date in date,
                     p_fy in number,
                     l_app IN Varchar2);


 PROCEDURE get_fiscal_year (aGl_date date, v_fy in out NOCOPY number) ;

 PROCEDURE cancel_trx(gPrefix IN Varchar2,
                      gSeq_Num IN NUMBER,
                      gSuffix IN Varchar2
                      ) ;

  Procedure ins_del(v_number_id in NUMBER,
                  vPrefix in varchar2,
                  vSuffix in varchar2,
                  vseq_num in number,
                  v_trx_date in date,
                  v_fy in number,
                  c_date in date,
                  l_app in varchar2);

  PROCEDURE redo_trx(pnumber_id in number,
                   pPrefix in out NOCOPY varchar2,
                   pSuffix in out NOCOPY varchar2,
                   pseq_val in out NOCOPY number,
                   pGL_date in date,
                   p_fy in number,
                   l_app IN Varchar2,
                   p_exp_num  in out NOCOPY varchar2);



 END IGIPFUNK;

 

/
