--------------------------------------------------------
--  DDL for Package MSC_CL_ITEM_ODS_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_ITEM_ODS_LOAD" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCLITES.pls 120.0 2007/04/12 08:36:51 vpalla noship $ */

--v_coll_prec                   MSC_CL_EXCHANGE_PARTTBL.CollParamRec;

    PROCEDURE GENERATE_ITEM_KEYS (ERRBUF		OUT NOCOPY VARCHAR2,
    			     RETCODE		OUT NOCOPY NUMBER,
                                 pINSTANCE_ID 	IN NUMBER);

     FUNCTION ITEM_NAME ( p_item_id                          IN NUMBER)
    		    RETURN VARCHAR2;

    PROCEDURE ADD_NEW_IMPL_ITEM_ASL;
    PROCEDURE UPDATE_LEADTIME;
    PROCEDURE LOAD_ITEM;
    PROCEDURE LOAD_SUPPLIER_CAPACITY;
    PROCEDURE LOAD_ABC_CLASSES;
    PROCEDURE LOAD_ITEM_SUBSTITUTES;
    PROCEDURE LOAD_CATEGORY;
END MSC_CL_ITEM_ODS_LOAD;

/
