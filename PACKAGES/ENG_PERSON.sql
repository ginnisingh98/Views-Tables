--------------------------------------------------------
--  DDL for Package ENG_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_PERSON" AUTHID CURRENT_USER AS
/* $Header: ENGEMPDS.pls 120.0.12000000.1 2007/07/25 09:36:31 sandpand noship $ */
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
 Name        : eng_person  (HEADER)

 Description : This package declares procedures required to validate people
               to be deleted from the database. It is used primarily by the
               Delete Person form (PAYPEDED).

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    21-DEC-92 PBARRY               Date Created
 ================================================================= */
--
  PROCEDURE eng_predel_validation (p_person_id  IN number);
--
END eng_person;

 

/
