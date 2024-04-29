--------------------------------------------------------
--  DDL for Package FND_SOS_SERVICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SOS_SERVICE" AUTHID CURRENT_USER AS
/* $Header: fndsoss.pls 120.1.12010000.1 2009/08/17 03:07:11 snellepa noship $ */

PROCEDURE AUTHENTICATE( p_user_name IN VARCHAR2 ,
                        p_password  IN VARCHAR2 ,
                        login_status OUT nocopy VARCHAR2,
                        user_id OUT nocopy NUMBER,
                        description out nocopy VARCHAR2,
                        user_status OUT nocopy VARCHAR2,
                        languages OUT nocopy VARCHAR2,
                        session_id OUT nocopy NUMBER,
                        xsid OUT NOCOPY VARCHAR2 ,
                        apps_database_id out NOCOPY VARCHAR2
                         );


        FUNCTION validate_user_cookie(p_user_name VARCHAR2 ,
                                      p_password  VARCHAR2)
                RETURN VARCHAR2;

        END FND_SOS_SERVICE;

/
