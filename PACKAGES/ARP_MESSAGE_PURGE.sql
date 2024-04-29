--------------------------------------------------------
--  DDL for Package ARP_MESSAGE_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_MESSAGE_PURGE" AUTHID CURRENT_USER AS
/* $Header: ARPUMSGS.pls 115.1 2002/11/15 02:49:21 anukumar ship $ */

 PROCEDURE get_message (m_name     Varchar2,
                        m_appshort Varchar2,
           	        m_num_of   BINARY_INTEGER,
                        m_token1   Varchar2,
                        m_value1   Varchar2,
                        m_token2   Varchar2,
                        m_value2   Varchar2,
                        m_token3   Varchar2,
                        m_value3   Varchar2,
                        m_message IN OUT NOCOPY Varchar2);
END arp_message_purge;

 

/
