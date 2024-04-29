--------------------------------------------------------
--  DDL for Package Body GMO_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_SETUP_PVT" 
/* $Header: GMOVSTPB.pls 120.1 2005/08/08 03:51 swasubra noship $ */

AS

--This procedure enables GMO profile option that would enable process operation modules
--to start functioning in the environment.
--This procedure is called through a concurrent program request.
PROCEDURE ENABLE_GMO(ERRBUF    OUT NOCOPY VARCHAR2,
                     RETCODE   OUT NOCOPY VARCHAR2)

IS

--This variable would hold the current value of of the GMO_ENABLED_FLAG profile option.
L_CURRENT_VALUE VARCHAR2(10);

--This variable would indicate if the profile option was updated successfully.
L_STATUS        BOOLEAN;

BEGIN

  --Obtain the current value of the profile option GMO_ENABLED_FLAG.
  L_CURRENT_VALUE := FND_PROFILE.VALUE('GMO_ENABLED_FLAG');

  IF L_CURRENT_VALUE <> 'Y' THEN

    --The profile option ios switched off.
    --Hence switch on the profile option.
    L_STATUS := FND_PROFILE.SAVE(X_NAME       => 'GMO_ENABLED_FLAG',
                                 X_VALUE      => 'Y',
  		                 X_LEVEL_NAME => 'SITE');

    --Set the message name based on the status value.
    IF L_STATUS THEN
      FND_MESSAGE.SET_NAME('GMO','GMO_SETUP_ENABLED_SUCCESS');
    ELSE
    FND_MESSAGE.SET_NAME('GMO','GMO_SETUP_ENABLE_FAILURE');
    END IF;

  ELSE
    --For some reason the profile option could not be updated.
    --Set the message appropriately to indicate the same.
      FND_MESSAGE.SET_NAME('GMO','GMO_SETUP_ALREADY_ENABLED');
  END IF;

  --Set the message on the log.
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);

  --Commit the transaction.
  COMMIT;

END ENABLE_GMO;

END GMO_SETUP_PVT;

/
