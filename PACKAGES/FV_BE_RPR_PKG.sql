--------------------------------------------------------
--  DDL for Package FV_BE_RPR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_BE_RPR_PKG" AUTHID CURRENT_USER AS
-- $Header: FVBERPRS.pls 120.2 2002/11/11 19:58:01 ksriniva ship $    |

procedure main ( errbuf        OUT NOCOPY varchar2,
            	 retcode       OUT NOCOPY varchar2,
	    	 p_sob_id          number,
		 p_approval_id     number,
	    	 p_submitter_id    number,
	   	 p_approver_id     number,
	    	 p_note    	   varchar2
            );

procedure set_hdr_fields (p_count number,
			  p_trx_hdr_rec  OUT NOCOPY fv_be_trx_hdrs%ROWTYPE,
			  p_rpr_rec  fv_be_rpr_transactions%ROWTYPE);

procedure set_dtl_fields (p_count number,
			  p_trx_dtl_rec  OUT NOCOPY fv_be_trx_dtls%ROWTYPE,
			  p_rpr_rec fv_be_rpr_transactions%ROWTYPE);

procedure insert_hdr_record(p_trx_hdr_rec fv_be_trx_hdrs%ROWTYPE);

procedure insert_dtl_record (p_trx_dtl_rec fv_be_trx_dtls%ROWTYPE);

procedure reset_doc_status(p_from_doc_id NUMBER, p_to_doc_id NUMBER);

end fv_be_rpr_pkg;

 

/
