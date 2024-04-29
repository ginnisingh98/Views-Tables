--------------------------------------------------------
--  DDL for Package OKC_HZ_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_HZ_MERGE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPMRGS.pls 120.0 2005/05/25 19:42:53 appldev noship $ */
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
-- Start of Comments
-- API Name     :OKC_HZ_MERGE_PUB
-- Type         :Public
-- Purpose      :Manage customer and party merges
--
-- Modification History
-- 07-Dec-00    mconnors    created
--
-- Notes        :
--
-- End of comments

PROCEDURE merge_account (req_id IN NUMBER
                        ,set_number  IN NUMBER
                        ,process_mode IN VARCHAR2);

END; -- Package Specification OKC_HZ_MERGE_PUB

 

/
