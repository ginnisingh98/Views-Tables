--------------------------------------------------------
--  DDL for Package PAY_US_RETRO_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_RETRO_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: payusretroupg.pkh 120.0.12010000.1 2008/07/27 21:56:21 appldev ship $ */
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
   ******************************************************************

   Name        : pay_us_retro_upgrade

   Description : This procedure is used to upgrade elements for
                 Enhanced Retropay.

   Change List
   -----------
   Date        Name       Vers   Bug No   Description
   ----------- ---------- ------ -------- -----------------------------------
   05-DEC-2004 ahanda     115.0           Intial Version

*/

 PROCEDURE qualify_element(p_object_id  in        varchar2
                          ,p_qualified out nocopy varchar2);

 PROCEDURE upgrade_element(p_element_type_id in number);

END pay_us_retro_upgrade;

/
