--------------------------------------------------------
--  DDL for Package IGF_SL_CL_LI_IMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_CL_LI_IMP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFSL19S.pls 120.0 2005/06/01 13:30:52 appldev noship $ */

--=========================================================================
--   Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA
--                               All rights reserved.
-- ========================================================================
--
--  DESCRIPTION
--         PL/SQL Spec for package: IGF_SL_CL_LI_IMP_PKG
--
--  NOTES
--
--  This package is used to import the legacy FFELP Loan and Disbursement data in the system.
--
----------------------------------------------------------------------------------
-- CHANGE HISTORY
----------------------------------------------------------------------------------
--  who              when            what
--  gmuralid         24-jun-2003     Created the Spec.
----------------------------------------------------------------------------------

PROCEDURE run (  errbuf         IN OUT NOCOPY VARCHAR2,
                 retcode        IN OUT NOCOPY NUMBER,
                 p_awd_yr       IN VARCHAR2,
                 p_batch_id     IN NUMBER,
                 p_delete_flag  IN VARCHAR2
               );

TYPE message_rec IS RECORD(
                       msg_text      VARCHAR2(400)
                          );

TYPE igf_sl_msg_table IS TABLE OF message_rec INDEX BY BINARY_INTEGER;



END IGF_SL_CL_LI_IMP_PKG;

 

/
