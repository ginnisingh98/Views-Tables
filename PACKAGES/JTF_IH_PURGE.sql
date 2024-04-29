--------------------------------------------------------
--  DDL for Package JTF_IH_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_PURGE" AUTHID CURRENT_USER AS
/* $Header: JTFIHPRS.pls 120.2 2005/07/02 02:07:47 appldev ship $ */
-- G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_IH_PURGE';
-- Program History
-- 09-OCT-2002  Igor Aleshin    Created.
-- 26-NOV-2002  Igor Aleshin    Added parameters: Outcome, Result, Reason for Activity and Interaction
-- 13-JAN-2003  Igor Aleshin    Added parameter p_Active default 'N'
-- 07-MAY-2004	Igor Aleshin	Fixed File.sql.35 issue
-- 29-DEC-2004	Neha Chourasia	Bug 4063673 fix for date range purge not working for Active set to Y
-- 25-FEB-2005	Neha Chourasia	ER 4007013 Added API PURGE_BY_OBJECT to purge interactions and
--                              activities related to the object passed.


    TranRows NUMBER;        -- How many deleted rows has each transaction.
    p_commit VARCHAR2(1);    -- Commit or not.
    PROCEDURE PURGE(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY VARCHAR2,
        p_Party_IDs VARCHAR2 DEFAULT NULL,
        p_Party_Type VARCHAR2 DEFAULT NULL,
        p_Active VARCHAR2 DEFAULT NULL, -- Bug# 4063673 - changed position from last param to 3rd
        p_Start_Date DATE DEFAULT NULL,
        p_End_Date DATE DEFAULT NULL,
        p_SafeMode VARCHAR2 DEFAULT NULL,
        p_Purge_Type VARCHAR2 DEFAULT NULL,
        -- Added 26-NOV-2002
        p_ActivityOutcome VARCHAR2 DEFAULT NULL,
        p_ActivityResult VARCHAR2 DEFAULT NULL,
        p_ActivityReason VARCHAR2 DEFAULT NULL,
        p_InterOutcome VARCHAR2 DEFAULT NULL,
        p_InterResult VARCHAR2 DEFAULT NULL,
        p_InterReason VARCHAR2 DEFAULT NULL
        );
  PROCEDURE P_DELETE_INTERACTIONS (
        p_api_version      IN NUMBER,
        p_init_msg_list  IN VARCHAR2 ,
        p_commit          IN  VARCHAR2,
        x_return_status  OUT NOCOPY VARCHAR2,
        x_msg_data        OUT  NOCOPY VARCHAR2,
        x_msg_count      OUT  NOCOPY NUMBER,
        p_processing_set_id IN NUMBER,
        p_object_type IN VARCHAR2
        );
END;

 

/
