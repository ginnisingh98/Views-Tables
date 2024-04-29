--------------------------------------------------------
--  DDL for Package ICXSUNWF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICXSUNWF" AUTHID CURRENT_USER as
--$Header: ICXWFSNS.pls 115.2 99/07/17 03:31:32 porting ship $
--
--
	procedure StartNameProcess(p_username           in varchar2,
				   p_supplier_id	in number,
			           p_email_address      in varchar2,
			           p_itemkey            in varchar2);
--
--
	procedure Add_Domain(itemtype        in varchar2,
                      itemkey                in varchar2,
                      actid                  in number,
                      funmode                in varchar2,
                      result                 out varchar2 );
--
--
       procedure Verify_Name(itemtype        in varchar2,
		      itemkey 		     in varchar2,
                      actid                  in number,
                      funmode                in varchar2,
                      result                 out varchar2 );
--
--
end icxsunwf;

 

/
