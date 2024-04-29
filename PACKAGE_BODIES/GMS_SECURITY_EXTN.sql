--------------------------------------------------------
--  DDL for Package Body GMS_SECURITY_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_SECURITY_EXTN" AS
/* $Header: gmsseexb.pls 120.1 2005/07/26 14:38:26 appldev ship $ */

  PROCEDURE check_award_access ( X_award_id                IN NUMBER
                                 , X_person_id             IN NUMBER
                                 , X_calling_module        IN VARCHAR2
                                 , X_event                 IN VARCHAR2
                                 , X_value                 OUT NOCOPY VARCHAR2 )
  IS
    -- Declare local variables

    X_award_num 	VARCHAR2(25);

  BEGIN

    IF ( X_event = 'ALLOW_QUERY' ) THEN

      -- The default behavior is to only allow access to the Award Status Inquiry
      -- window to key members of the award.  All other windows will display all
      -- awards by default.

      -- GMS provides an API to determine
      -- whether or not a given person is an active key member on a specified
      -- award.  This function, CHECK_KEY_MEMBER is defined in the
      -- GMS_SECURITY package.  It takes two input parameters, person_id and
      -- award_id, and returns as output: 'Y' if the person is an active
      -- key member for the award, and 'N' if the person is not.

      -- Note, if NULL values are passed for either parameter, person or
      -- award, then the function returns NULL.

        -- Code can be added here as per the business rules.
        --Added to fix bug # 866342
      IF (X_calling_module = 'GMSAWASI') THEN
         X_value :=  gms_security.check_key_member( X_person_id, X_award_id );
      ELSE
         X_value := 'Y';
      END IF;

      RETURN;


    ELSIF ( X_event = 'ALLOW_UPDATE' ) THEN

      -- Note that a user must be granted ALLOW_QUERY access for a award
      -- in order for this function to be called for that user and award.
      -- Since  validates key members during ALLOW_QUERY, there is no
      -- additional default validation in at the ALLOW_UPDATE level.


      -- Code can be added here as per the business rules.
      X_value := 'Y';
      RETURN;


    END IF;

  END check_award_access;

END gms_security_extn;

/
