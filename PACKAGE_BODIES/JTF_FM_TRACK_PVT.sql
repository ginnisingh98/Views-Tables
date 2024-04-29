--------------------------------------------------------
--  DDL for Package Body JTF_FM_TRACK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FM_TRACK_PVT" AS
/* $Header: jtfvfmtb.pls 115.7 2003/08/26 15:43:22 abuddhav ship $*/
  g_pkg_name   CONSTANT VARCHAR2(30) := 'JTF_FM_TRACK_PVT';
  g_file_name  CONSTANT VARCHAR2(12) := 'JTFVFMTB.PLS';


-----------------------------------------------------------------------------
-- PROCEdURE
--   TRACK_IMAGE
--    This procedure takes in 2 parameters
--	  REQUEST_ID
--	  PARTY_ID
--    This procedure updates JTF_FM_CONTENT_HISTORY
--    It updates all the records with the specified
--    request id and the party id to 'OPENED'
--    There might be multiple records for the same
--    request for a party id based on number of contents.
--
--
-- HISTORY
--    10/15/2002  abuddhav CREATE.
-----------------------------------------------------------------------------
PROCEDURE TRACK_IMAGE
(
   p_request_history_id    IN NUMBER,
   p_customer_id           IN NUMBER
)
IS

   l_email_status VARCHAR2(15);
   BEGIN

     SELECT DISTINCT EMAIL_STATUS INTO l_email_status FROM JTF_FM_PROCESSED WHERE
     REQUEST_ID = p_request_history_id AND PARTY_ID = p_customer_id;

     IF l_email_status is NULL OR  (l_email_status <> 'UNSUBSCRIBED' AND l_email_status <> 'OPENED')
     THEN
            UPDATE JTF_FM_PROCESSED
            SET EMAIL_STATUS = 'OPENED'
            WHERE request_id =p_request_history_id AND
            party_id = p_customer_id ;

            UPDATE JTF_FM_EMAIL_STATS
            SET    OPENED = NVL(opened, 0) + 1
            WHERE  request_id = p_request_history_id;
     END IF;

	 COMMIT WORK;
END TRACK_IMAGE;
-----------------------------------------------------------------------------------


PROCEDURE UNSUBSCRIBE_USER
(
   p_request_history_id    IN NUMBER,
   p_customer_id           IN NUMBER
)
IS


  l_email_status  VARCHAR2(15);

  BEGIN

     SELECT DISTINCT EMAIL_STATUS INTO l_email_status FROM JTF_FM_PROCESSED WHERE
     REQUEST_ID = p_request_history_id AND PARTY_ID = p_customer_id;


     IF l_email_Status <> 'UNSUBSCRIBED'
     THEN
       UPDATE JTF_FM_PROCESSED
       SET EMAIL_STATUS = 'UNSUBSCRIBED'
       WHERE request_id =p_request_history_id AND
       party_id = p_customer_id ;

       UPDATE JTF_FM_EMAIL_STATS
       SET    UNSUBSCRIBED = NVL(UNSUBSCRIBED,0) + 1
       WHERE  request_id = p_request_history_id;
     END IF;

	 COMMIT WORK;
    END UNSUBSCRIBE_USER;


PROCEDURE TRACK_BOUNCEBACK
(
   p_request_history_id    IN NUMBER,
   p_customer_id           IN NUMBER
)
IS


  l_email_status  VARCHAR2(15);

  BEGIN

       UPDATE JTF_FM_PROCESSED
       SET EMAIL_STATUS = 'BOUNCED'
       WHERE request_id =p_request_history_id AND
       party_id = p_customer_id ;

       UPDATE JTF_FM_EMAIL_STATS
       SET    BOUNCED = NVL(BOUNCED,0) + 1
       WHERE  request_id = p_request_history_id;
	 COMMIT WORK;
    END TRACK_BOUNCEBACK;

END Jtf_Fm_Track_Pvt;

/
