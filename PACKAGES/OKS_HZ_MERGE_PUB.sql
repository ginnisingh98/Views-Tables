--------------------------------------------------------
--  DDL for Package OKS_HZ_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_HZ_MERGE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPMRGS.pls 120.0 2005/05/25 18:14:13 appldev noship $ */
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
-- Start of Comments
-- API Name     :OKS_HZ_MERGE_PUB
-- Type         :Public
-- Purpose      :Manage customer and party merges
--
-- Modification History
-- 14-Dec-00    mconnors    created
--
-- Notes        :
--
-- End of comments

PROCEDURE merge_account (req_id IN NUMBER
                        ,set_number  IN NUMBER
                        ,process_mode IN VARCHAR2);

END; -- Package Specification OKS_HZ_MERGE_PUB

 

/
