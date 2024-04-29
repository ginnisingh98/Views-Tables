--------------------------------------------------------
--  DDL for Package PAY_GB_RETRO_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_RETRO_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: paygbretroupg.pkh 120.0 2005/09/23 02:51 rmakhija noship $ */
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

   Name        : pay_gb_retro_upgrade

   Description : This procedure is used to upgrade elements for
                 Enhanced Retropay.

   Change List
   -----------
   Date        Name       Vers   Bug No   Description
   ----------- ---------- ------ -------- -----------------------------------
   19-Jul-2005 rmakhija   115.0           Intial Version copied from
                                          paygbretroupg.pkh

*/

 PROCEDURE qualify_element(p_object_id  in        varchar2
                          ,p_qualified out nocopy varchar2);

 PROCEDURE upgrade_element(p_element_type_id in number);

END pay_gb_retro_upgrade;

 

/
