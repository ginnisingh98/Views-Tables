--------------------------------------------------------
--  DDL for Package GHR_SES_CONV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_SES_CONV_PKG" 
/* $Header: ghsescon.pkh 115.1 2004/02/02 20:48:44 asubrahm noship $ */
AUTHID CURRENT_USER AS

--
-- While SES position conversions, in the history row creation of 11-JAN-2004 date,
-- future rows should not be cascaded with pay table id of ESSL.
--

g_do_not_cascade  varchar2(1) := 'N';

-- ---------------------------------------------------------------------------
--  |--------------------< ghr_ses_pay_cal_conv >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Used with Concurrent Program - Process SES Pay Conversion
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE ghr_ses_pay_cal_conv
(
    errbuf              OUT NOCOPY VARCHAR2 ,
    retcode             OUT NOCOPY NUMBER   ,
    p_business_group_id            NUMBER   DEFAULT NULL
  );
END GHR_SES_CONV_PKG;

 

/
