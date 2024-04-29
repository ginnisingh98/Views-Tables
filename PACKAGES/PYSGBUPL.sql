--------------------------------------------------------
--  DDL for Package PYSGBUPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PYSGBUPL" AUTHID CURRENT_USER AS
-- /* $Header: pysgbupl.pkh 115.3 2002/12/11 06:04:27 apunekar ship $ */
--
-- +======================================================================+
-- |              Copyright (c) 1997 Oracle Corporation UK Ltd            |
-- |                        Reading, Berkshire, England                   |
-- |                           All rights reserved.                       |
-- +======================================================================+
-- SQL Script File Name : pysgbupl.pkh
-- Description          : This script delivers Initial Balance Structure Creation.
--                        package for the Singapore localization (SG).
--                        This package can be activated from the SG Initial Balance
--                        Structure Creation SRS available through Forms.  The user
--                        needs to supply the batch name to run this process.
--
--                        Given the limit of the input values per element type and the
--                        batch id in that order, create_bal_upl_struct will first call
--                        validate_batch_data to validate the batch data, then it will
--                        create the element types, element links, input values, balance
--                        feeds and link input values.
--
--
-- Change List:
-- ------------
--
-- ======================================================================
-- Version  Date         Author    Bug No.  Description of Change
-- -------  -----------  --------  -------  -----------------------------
-- 115.0    30-JUN-2000  JBailie            Initial Version
-- 115.1    21-JUL-2000  JBailie            Set ship state
-- 115.2    29-NOV-2001  Ragovind 2129823   GSCC Compliance Check
-- 115.3    10-DEC-2002 Apunekar  2689242   Added nocopy to out and in out parameters
-- ======================================================================
--
--
--
   PROCEDURE create_bal_upl_struct (errbuf                OUT NOCOPY varchar2,
                                    retcode               OUT NOCOPY number,
                                    p_input_value_limit       number,
                                    p_batch_id                number);
--
END pysgbupl;

 

/
