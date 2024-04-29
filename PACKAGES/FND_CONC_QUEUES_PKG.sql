--------------------------------------------------------
--  DDL for Package FND_CONC_QUEUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_QUEUES_PKG" AUTHID CURRENT_USER as
/* $Header: AFCPFCQS.pls 115.0 99/07/16 23:10:53 porting ship $ */

  function check_deletability	(qid	in number,
				 appid	in number,
				 qname in varchar2)
	    			 return boolean;
  pragma restrict_references    (check_deletability, WNDS);

  procedure check_unique_queue	(ro_id  in varchar2,
				 appid	in number,
				 qname	in varchar2,
                                 uqname in varchar2);

  procedure check_unique_wkshift (appid	in number,
				 qid	in number,
				 ro_id	in varchar2,
				 pappid	in number,
				 tpid	in number);

  procedure check_conflicts	(iflag  in varchar2,
				 qid	in number,
				 qappid	in number,
				 tcode	in varchar2,
				 tid	in number,
				 tappid	in number,
				 ro_id	in varchar2);


end FND_CONC_QUEUES_PKG;

 

/
