--------------------------------------------------------
--  DDL for Package HR_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DELETE" AUTHID CURRENT_USER AS
/* $Header: pedelete.pkh 115.2 2003/01/16 13:16:16 adhunter ship $ */
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
 ==================================================================

 Name        : hr_delete  (HEADER)

 Description : Contains the declaration of general delete procedures

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    17-NOV-92 SZWILLIA             Date Created
 70.1    11-MAR-93 nkhan                added 'exit' to the end
 70.2    06-oct-95 akelly               added new procedure delete_location
 70.3    15-oct-95 akelly               removed the offending delete_location
                                        procedure.
 70.8    01-nov-95 dsaxby               Added p_preserve_org_information param.
 70.9    18-nov-96 Tmathers             Added p_preserve_org_information param
													 to make rt's re-runnable.
*/
--
--
PROCEDURE delete_below_bg(p_business_group_id NUMBER,
                          p_preserve_org_information in VARCHAR2 default 'N',
                          p_rt_running in VARCHAR2 default 'N');
--
--
--
end hr_delete;

 

/
