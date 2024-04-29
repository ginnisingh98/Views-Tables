--------------------------------------------------------
--  DDL for Package IGP_AD_USERID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGP_AD_USERID_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPADAS.pls 120.0 2005/06/01 18:34:46 appldev noship $ */
/*
||  Created By : nsidana
||  Created On :  1/28/2004
||  Purpose :  Main package specs for Portfolio user creation and deactivation.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/

PROCEDURE   CHECK_EXISTING_ACCOUNT(itemtype       IN              VARCHAR2,
                                                                                      itemkey         IN              VARCHAR2,
                                                                                      actid              IN              NUMBER,
                                                                                      funcmode     IN              VARCHAR2,
                                                                                      resultout       OUT NOCOPY      VARCHAR2 );

PROCEDURE   RECORD_DATA(itemtype       IN              VARCHAR2,
                                                            itemkey         IN              VARCHAR2,
                                                            actid              IN              NUMBER,
                                                            funcmode     IN              VARCHAR2,
                                                            resultout       OUT NOCOPY      VARCHAR2 );

PROCEDURE   CHECK_ACTION(itemtype       IN              VARCHAR2,
                                                            itemkey         IN              VARCHAR2,
                                                            actid              IN              NUMBER,
                                                            funcmode     IN              VARCHAR2,
                                                            resultout       OUT NOCOPY      VARCHAR2 );

PROCEDURE   VALIDATE_USER_NAME(itemtype       IN              VARCHAR2,
                                                                             itemkey         IN              VARCHAR2,
                                                                             actid              IN              NUMBER,
                                                                             funcmode     IN              VARCHAR2,
                                                                             resultout       OUT NOCOPY      VARCHAR2 );

PROCEDURE   CREATE_FND_USER(itemtype       IN              VARCHAR2,
                                                                    itemkey         IN              VARCHAR2,
                                                                    actid              IN              NUMBER,
                                                                    funcmode     IN              VARCHAR2,
                                                                    resultout       OUT NOCOPY      VARCHAR2 );

PROCEDURE   CREATE_PORT_ACCOUNT(itemtype       IN              VARCHAR2,
                                                                                itemkey         IN              VARCHAR2,
                                                                                actid              IN              NUMBER,
                                                                                funcmode     IN              VARCHAR2,
                                                                                resultout       OUT NOCOPY      VARCHAR2 );

PROCEDURE   SET_DATA(itemtype       IN              VARCHAR2,
                                                  itemkey         IN              VARCHAR2,
                                                  actid              IN              NUMBER,
                                                  funcmode     IN              VARCHAR2,
                                                  resultout       OUT NOCOPY      VARCHAR2 );

PROCEDURE   CLEANUP(itemtype       IN             VARCHAR2,
                                                  itemkey         IN              VARCHAR2,
                                                  actid              IN              NUMBER,
                                                  funcmode     IN              VARCHAR2,
                                                  resultout       OUT NOCOPY      VARCHAR2 );

FUNCTION GENERATE_PASSWORD ( p_party_id NUMBER) RETURN VARCHAR2;

END igp_ad_userid_pkg;

 

/
