--------------------------------------------------------
--  DDL for Package AS_PIPELINE_MOVE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_PIPELINE_MOVE_PUB" AUTHID CURRENT_USER as
/* $Header: asxppmvs.pls 120.1 2005/06/05 22:52:24 appldev  $ */

--
-- HISTORY
--   02/27/01  ACNG     Created.
-- NOTES
--   The main package for the concurrent program "Pipeline movement"
--
/************************************************************/
/* This script is used to move sales credits and access     */
/* records from one salesforce to another salesforce        */
/* Input required : User login      (from which user      ) */
/*                  group name      (from which salesgroup) */
/*                  User login      ( to  which user      ) */
/*                  group name      ( to  which salesgroup) */
/*                  win probability (win probability range) */
/*                  decision date   (close date range     ) */
/*                  status          (statuses             ) */
/************************************************************/
/********************************************************************************/
/* Instruction to run this SQL script, parameters are in sequence               */
/* 1) from_user_name  (move from which salesforce)                              */
/* 2) to_user_name    (move to which salesforce)                                */
/* 3) from_group_name (move from group where the salesforce belongs to)         */
/* 4) to_group_name   (move to group where the salesforce belongs to)           */
/* 5) from_win_prob (move sales credits with win prob range starts from)        */
/*    Default value = 0 if no input from user                                   */
/* 6) to_win_prob (move sales credits with win prob range ends at)              */
/*    Default value = 100 if no input from user                                 */
/* 7) from_close_date (decision date range starts from)                         */
/*    Please input the date as the following format                             */
/*    e.g.: 01-JAN-1999                                                         */
/*    Default value = 01-JAN-1900                                               */
/* 8) to_close_date (decision date range ends at)                               */
/*    Please input the date as the following format                             */
/*    e.g.: 01-JAN-1999                                                         */
/*    Default value = 01-JAN-4712                                               */
/* 9) Statuses : all leads with these statuses will be moved                    */
/*    Please input a list of statuses separated by comma (,)                    */
/*    e.g.: won,preliminary                                                     */
/*    Default value = all statuses if no input from user                        */
/********************************************************************************/
/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |  Pipeline_Movement
 |
 | PURPOSE
 |  The main program for pipeline movement.
 | NOTES
 |
 | HISTORY
 |   02/27/01  ACNG     Created
 *-------------------------------------------------------------------------*/

PROCEDURE Pipeline_Movement(
    ERRBUF                OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    RETCODE               OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    p_from_user           IN  VARCHAR2,
    p_from_grp            IN  VARCHAR2,
    p_to_user             IN  VARCHAR2,
    p_to_grp              IN  VARCHAR2,
    p_from_win_prob       IN  NUMBER := NULL,
    p_to_win_prob         IN  NUMBER := NULL,
    p_from_close_date     IN  DATE := NULL,
    p_to_close_date       IN  DATE := NULL,
    p_status              IN  VARCHAR2 := NULL);

/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |  Pipeline_Movement for sales credits only
 |
 | PURPOSE
 |  The main program for pipeline movement for sales credits only
 | NOTES
 |
 | HISTORY
 |   02/27/01  ACNG     Created
 *-------------------------------------------------------------------------*/

PROCEDURE Pipeline_SC_Movement(
    ERRBUF                OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    RETCODE               OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    p_from_user           IN  VARCHAR2,
    p_from_grp            IN  VARCHAR2,
    p_to_user             IN  VARCHAR2,
    p_to_grp              IN  VARCHAR2,
    p_from_win_prob       IN  NUMBER := NULL,
    p_to_win_prob         IN  NUMBER := NULL,
    p_from_close_date     IN  DATE := NULL,
    p_to_close_date       IN  DATE := NULL,
    p_status              IN  VARCHAR2 := NULL);

END AS_PIPELINE_MOVE_PUB;

 

/
