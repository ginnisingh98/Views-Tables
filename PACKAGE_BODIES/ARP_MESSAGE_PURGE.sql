--------------------------------------------------------
--  DDL for Package Body ARP_MESSAGE_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_MESSAGE_PURGE" AS
/* $Header: ARPUMSGB.pls 115.1 2002/11/15 02:49:10 anukumar ship $ */

 PROCEDURE get_message (m_name     Varchar2,
                        m_appshort Varchar2,
           	        m_num_of   BINARY_INTEGER,
                        m_token1   Varchar2,
                        m_value1   Varchar2,
                        m_token2   Varchar2,
                        m_value2   Varchar2,
                        m_token3   Varchar2,
                        m_value3   Varchar2,
                        m_message IN OUT NOCOPY Varchar2)  AS

    BEGIN

       FND_MESSAGE.SET_NAME(m_appshort, m_name);

       IF (m_num_of > 0) THEN

          FND_MESSAGE.SET_TOKEN(m_token1, m_value1, FALSE);

          IF (m_num_of > 1) THEN

             FND_MESSAGE.SET_TOKEN(m_token2, m_value2, FALSE);

             IF (m_num_of > 2) THEN

                FND_MESSAGE.SET_TOKEN(m_token3, m_value3, FALSE);

             END IF;

          END IF;

       END IF;

       m_message := FND_MESSAGE.GET;

    END;

END arp_message_purge;

/
