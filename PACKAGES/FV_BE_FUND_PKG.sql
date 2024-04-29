--------------------------------------------------------
--  DDL for Package FV_BE_FUND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_BE_FUND_PKG" AUTHID CURRENT_USER AS
-- $Header: FVBEFDCS.pls 120.6 2005/08/17 14:53:34 rshergil ship $    |

 procedure conc_main ( errbuf        OUT NOCOPY varchar2,
            	 retcode       OUT NOCOPY varchar2,
	    	 p_mode            varchar2,
	    	 p_sob_id          number,
	   	 p_approval_id     number);

 --function seq return number;

 procedure main ( errbuf           OUT NOCOPY varchar2,
            	 retcode           OUT NOCOPY varchar2,
	    	 p_mode                       varchar2,
	    	 p_sob_id                     number,
	    	 p_doc_id                     number,
	   	 p_rpr_to_doc_id              number,
		 p_approver_id                number,
                 p_doc_type                   varchar2,
                 p_event_type                 varchar2,
                 p_accounting_date            date,
                 p_return_status   OUT NOCOPY VARCHAR2,
                 p_status_code     OUT NOCOPY VARCHAR2,
		 p_user_id                    number,
		 p_resp_id     	              number
            );

 procedure process_document(p_doc_id                       number,
                            p_doc_type                     varchar2,
                            p_event_type                   varchar2,
                            p_accounting_date              date,
                            x_return_status     OUT NOCOPY varchar2,
                            x_status_code       OUT NOCOPY varchar2,
                            p_calling_sequence             varchar2
);



 procedure  update_doc_status(p_doc_id NUMBER,
		       	p_retcode NUMBER);

 procedure delete_rpr_docs (p_doc_id number,
                           p_rpr_to_doc_id number);

 procedure log_message(p_message varchar2);

end fv_be_fund_pkg;

 

/
