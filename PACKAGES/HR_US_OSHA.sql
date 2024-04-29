--------------------------------------------------------
--  DDL for Package HR_US_OSHA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_US_OSHA" AUTHID CURRENT_USER AS
/* $Header: peusosha.pkh 120.1 2005/06/13 04:51:15 bshukla noship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
 *                   Chertsey, England.                           *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation UK Ltd,  *
 *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
 *  England.                                                      *
 *                                                                *
 ****************************************************************** */
/*
 Name        : hr_us_osha  (HEADER)

 Description : This package declares a function required to generate
	       OSHA-reportable incident case numbers.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    27-Apr-95 SSDESAI              Created
 115.1   13-AUG-01 GPERRY               Changed routine so that it creates
                                        unique case numbers and fills in
                                        missed numbers.
                                        WWBUG 1714703.
 115.2   13-JUN-05 bshukla              Added dbdrv statements for Bug
                                        4421316
 ================================================================= */
--
--
-- Called as a default for the Case Number segment of the
-- OSHA-reportable Incident Flex Structure.
--
--------------------------------------------------------------------
function generate_case_number return varchar2;
--------------------------------------------------------------------
--
END hr_us_osha;

 

/
