--------------------------------------------------------
--  DDL for Package Body HZ_MGD_MASS_UPDATE_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MGD_MASS_UPDATE_CP" AS
/* $Header: ARHCMUCB.pls 120.2 2005/06/30 04:46:18 bdhotkar noship $*/
/*+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    ARHCMUCB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Body of concurrent program package HZ_MGD_MASS_UPDATE_CP          |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Run_Mass_Update_Credit_Usages                                     |
--|                                                                       |
--| HISTORY                                                               |
--|     05/14/2002 tsimmond    Created                                    |
--|     11/27/2002 tsimmond    Updated   Added WHENEVER OSERROR EXIT      |
--|                                      FAILURE ROLLBACK                 |
--|                                                                       |
--+======================================================================*/


--========================================================================
-- PROCEDURE : Run_Mass_Update_Credit_Usages  PUBLIC
-- PARAMETERS: p_profile_class_id     Profile Class ID
--             p_currency_code        Currency Code
--             p_profile_class_amount_id
--             p_release              OLD or NEW(is when AR Credit Management
--                                    is installed)
--             x_errbuf               error buffer
--             x_retcode              0 success, 1 warning, 2 error
--
-- COMMENT   : This is the concurrent program for mass update update credit usages
--
--========================================================================
PROCEDURE Run_Mass_Update_Credit_Usages
( x_errbuf            OUT NOCOPY  VARCHAR2
, x_retcode           OUT NOCOPY VARCHAR2
, p_profile_class_id  IN  NUMBER
, p_currency_code     IN  VARCHAR2
, p_profile_class_amount_id IN NUMBER
, p_release           IN VARCHAR2
)
IS
l_errbuf  VARCHAR2(2000);
l_retcode VARCHAR2(2000);

BEGIN
  -- initialize the message stack
  FND_MSG_PUB.Initialize;


  HZ_MGD_MASS_UPDATE_REP_GEN.Initialize;

  HZ_MGD_MASS_UPDATE_REP_GEN.log( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_PROCEDURE
                            , p_msg => '>> Run_Mass_Update_Credit_Usages');

  -----assigning p_release to the global G_RELEASE
  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_STATEMENT
  , p_msg => 'assigning p_release to the global G_RELEASE='
             ||p_release
  );

  HZ_MGD_MASS_UPDATE_CP.G_RELEASE:=p_release;

  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_STATEMENT
  , p_msg => 'p_profile_class_id='||TO_CHAR(p_profile_class_id)
             ||'p_currency_code='||p_currency_code
  );


  HZ_MGD_MASS_UPDATE_MEDIATOR.Mass_Update_Usage_Rules
  ( p_profile_class_id        => p_profile_class_id
  , p_currency_code           => p_currency_code
  , p_profile_class_amount_id => p_profile_class_amount_id
  , x_errbuf                  => l_errbuf
  , x_retcode                 => l_retcode
  );

COMMIT;

  -- Print the Report
  HZ_MGD_MASS_UPDATE_REP_GEN.Generate_Report
  ( p_prof_class_id             => p_profile_class_id
  , p_currency_code             => p_currency_code
  , p_profile_class_amount_id   => p_profile_class_amount_id
  );

  HZ_MGD_MASS_UPDATE_REP_GEN.Log( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_PROCEDURE
                             , p_msg => '<< Run_Mass_Update_Credit_Usages');


  EXCEPTION
  WHEN OTHERS THEN
    HZ_MGD_MASS_UPDATE_REP_GEN.Log(HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_EXCEPTION,'SQLERRM '|| SQLERRM) ;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Run_Mass_Update_Credit_Usages');
    END IF;

    x_retcode := 2;
    x_errbuf  := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,255);
    ROLLBACK;
    RAISE;

END Run_Mass_Update_Credit_Usages;

END HZ_MGD_MASS_UPDATE_CP;

/
