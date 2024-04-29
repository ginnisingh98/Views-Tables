--------------------------------------------------------
--  DDL for Package POS_COMMON_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_COMMON_APIS" AUTHID CURRENT_USER AS
/* $Header: POSCOMAS.pls 115.1 2002/11/26 02:35:43 ammitra ship $ */

/*

--
--
	This package contains the common API used by all the WEB Supplier
	Workflows.

	Be extremely careful when modifying anything here as it will
	most likey impact all the web supplier workflows.

--
--

*/


--

PROCEDURE  Get_PO_Details_URL(	 document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	nocopy varchar2,
                                 document_type	in out	nocopy varchar2 );
--

procedure  get_supplier_username   ( 	itemtype        in  varchar2,
                            		itemkey         in  varchar2,
	                    		actid           in number,
                            		funcmode        in  varchar2,
                            		result          out nocopy varchar2    );

--

procedure  get_buyer_username   ( 	itemtype        in  varchar2,
                            		itemkey         in  varchar2,
	                    		actid           in number,
                            		funcmode        in  varchar2,
                            		result          out nocopy varchar2    );
--

procedure get_default_inventory_org ( 	itemtype        in  varchar2,
                            		itemkey         in  varchar2,
	                    		actid           in number,
                            		funcmode        in  varchar2,
                            		result          out nocopy varchar2    );
--

procedure set_attributes ( 	itemtype        in  varchar2,
                            	itemkey         in  varchar2,
	                    	actid           in number,
                            	funcmode        in  varchar2,
                            	result          out nocopy varchar2    );
--

procedure get_supplier ( 	itemtype        in  varchar2,
                            	itemkey         in  varchar2,
	                    	actid           in number,
                            	funcmode        in  varchar2,
                            	result          out nocopy varchar2    );
--

procedure purge_workflow ( x_document_id in number );

--

END POS_COMMON_APIS;

 

/
