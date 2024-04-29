--------------------------------------------------------
--  DDL for Package PAY_AU_RETRO_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_RETRO_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: payauretroupg.pkh 120.0.12010000.2 2010/03/10 07:50:13 pmatamsr ship $ */
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

   Name        : pay_au_retro_upgrade

   Description : This procedure is used to upgrade elements for
                 Enhanced Retropay.

   Change List
   -----------
   Date        Name       Vers   Bug No   Description
   ----------- ---------- ------ -------- -----------------------------------
   05-JAN-2006 ksingla     120.0           Intial Version

================================================================================================
11i Versions - Package backported to 11i - Bug 5731490
================================================================================================
   22-Dec-2006 avenkatk  115.0 5731490      Added Function  - set_retro_leg_rule
                                                  Procedure - create_enhanced_retro_defn
   04-Jan-2007 avenkakt  115.1 5731490      Added Procedure - set_enh_retro_request_group
                                                            - enable_au_enhanced_retro
   10-Mar-2010 pmatamsr  115.2 9299082      Added Procedure - enable_au_retro_overlap

*/

 PROCEDURE qualify_element(p_object_id  in        varchar2
                          ,p_qualified out nocopy varchar2);

 PROCEDURE upgrade_element(p_element_type_id in number);

 FUNCTION set_retro_leg_rule(p_calling_form in varchar2)
 RETURN varchar2;

 PROCEDURE create_enhanced_retro_defn;

 PROCEDURE set_enh_retro_request_group;

 PROCEDURE enable_au_enhanced_retro(
                               errbuf      OUT NOCOPY VARCHAR2
                              ,retcode     OUT NOCOPY NUMBER
                                );

 PROCEDURE enable_au_retro_overlap(
                                errbuf      OUT NOCOPY VARCHAR2
                               ,retcode     OUT NOCOPY NUMBER
                                 );
END pay_au_retro_upgrade;

/
