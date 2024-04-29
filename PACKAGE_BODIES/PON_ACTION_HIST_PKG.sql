--------------------------------------------------------
--  DDL for Package Body PON_ACTION_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_ACTION_HIST_PKG" AS
-- $Header: PONHISTB.pls 120.0 2005/06/01 18:14:43 appldev noship $

--========================================================================
-- PROCEDURE : InsertRowHandler  PRIVATE
-- COMMENT   : Table handler for PON_ACTION_HISTORY
--========================================================================

PROCEDURE InsertRowHandler( p_OBJECT_ID          IN    NUMBER,
                            p_OBJECT_ID2         IN    NUMBER,
                            p_OBJECT_TYPE_CODE   IN    VARCHAR2,
                            p_SEQUENCE_NUM       IN    NUMBER,
                            p_ACTION_TYPE        IN    VARCHAR2,
                            p_ACTION_USER_ID     IN    NUMBER,
                            p_ACTION_NOTE        IN    VARCHAR2,
                            p_ACTION_REASON_CODE IN    VARCHAR2
)

IS

BEGIN

insert into PON_ACTION_HISTORY( OBJECT_ID,
                                OBJECT_ID2,
                                OBJECT_TYPE_CODE,
                                SEQUENCE_NUM,
                                ACTION_TYPE,
                                ACTION_DATE,
                                ACTION_USER_ID,
                                ACTION_NOTE,
                                ACTION_REASON_CODE)
                        VALUES( p_OBJECT_ID,
                                p_OBJECT_ID2,
                                p_OBJECT_TYPE_CODE,
                                p_SEQUENCE_NUM,
                                p_ACTION_TYPE,
                                sysdate,
                                p_ACTION_USER_ID,
                                p_ACTION_NOTE,
                                p_ACTION_REASON_CODE);

END InsertRowHandler;


--========================================================================
-- PROCEDURE : UpdateRowHandler  PRIVATE
-- COMMENT   : Table handler for PON_ACTION_HISTORY
--========================================================================

PROCEDURE UpdateRowHandler( p_OBJECT_ID          IN    NUMBER,
                            p_OBJECT_ID2         IN    NUMBER,
                            p_OBJECT_TYPE_CODE   IN    VARCHAR2,
                            p_SEQUENCE_NUM       IN    NUMBER,
                            p_ACTION_TYPE        IN    VARCHAR2)

IS

BEGIN


UPDATE PON_ACTION_HISTORY
SET
ACTION_TYPE = p_action_type,
ACTION_DATE = sysdate
WHERE OBJECT_ID = p_object_id
and OBJECT_ID2 = p_object_id2
and OBJECT_TYPE_CODE = p_object_type_code
and SEQUENCE_NUM = p_sequence_num
and ACTION_TYPE is NULL;


END UpdateRowHandler;

--========================================================================
-- PROCEDURE : RecordHistory   PUBLIC
-- PARAMETERS: p_OBJECT_TYPE_CODE     => PON_SPOTBUY for Shopping Cart.
--                                       PON_AUCTIONS for Auctions.
--             p_ORDER_ID             => For Spot Buy => Order Header Number.
--                                       For Auctions =>
-- COMMENT   : Logic for determing values to insert into PON_ACTION_HISTORY
--========================================================================

PROCEDURE RecordHistory( p_OBJECT_ID           IN    NUMBER,
                         p_OBJECT_ID2          IN    NUMBER,
                         p_OBJECT_TYPE_CODE    IN    VARCHAR2,
                         p_ACTION_TYPE         IN    VARCHAR2,
                         p_ACTION_USER_ID      IN    NUMBER,
                         p_ACTION_NOTE         IN    VARCHAR2,
                         p_ACTION_REASON_CODE  IN    VARCHAR2,
                         p_ACTION_USER_ID_NEXT IN    NUMBER,
                         p_CONTINUE            IN    VARCHAR2)
IS


cursor chk_sequence_number(ln_objectid NUMBER, ln_objectid2 NUMBER, lv_type VARCHAR2) is
select max(pah.sequence_num)
from PON_ACTION_HISTORY PAH
where PAH.OBJECT_ID = ln_objectid
and (PAH.OBJECT_ID2 = ln_objectid2 OR PAH.OBJECT_ID2 is null)
and PAH.OBJECT_TYPE_CODE = lv_type;

ln_seq_number NUMBER;
ln_new_seq_number NUMBER;

BEGIN

        OPEN chk_sequence_number(p_object_id, p_object_id2, p_object_type_code);
        FETCH chk_sequence_number into ln_seq_number;
        CLOSE chk_sequence_number;

        IF (ln_seq_number >= 0) THEN -- Insert into PON_ACTION_HISTORY with the same OBJECT_IDS

          ln_new_seq_number := ln_seq_number + 1;

        ELSE

          ln_seq_number := 0;
          ln_new_seq_number := 0;

        END IF;


        IF (p_continue = 'N') THEN -- We are not going to be creating two rows or updating

          -- Call the RowHandler Procedure to insert a row into the table PON_ACTION_HISTORY

          InsertRowHandler( p_OBJECT_ID          =>  p_object_id,
                            p_OBJECT_ID2         =>  p_object_id2,
                            p_OBJECT_TYPE_CODE   =>  p_object_type_code,
                            p_SEQUENCE_NUM       =>  ln_new_seq_number,
                            p_ACTION_TYPE        =>  p_action_type,
                            p_ACTION_USER_ID     =>  p_action_user_id,
                            p_ACTION_NOTE        =>  p_action_note,
                            p_ACTION_REASON_CODE =>  p_action_reason_code);

        ELSIF (p_continue = 'F') THEN -- We are just going to update the existing row.


                             UpdateRowHandler( p_OBJECT_ID          =>  p_object_id,
                                               p_OBJECT_ID2         =>  p_object_id2,
                                               p_OBJECT_TYPE_CODE   =>  p_object_type_code,
                                               p_SEQUENCE_NUM       =>  ln_seq_number,
                                               p_ACTION_TYPE        =>  p_action_type);


        ELSE
                  if (ln_new_seq_number = 0) then
                      -- If the sequence number is 0 then we have two create two rows as this is a new entry

                      -- First with the current information
                             InsertRowHandler( p_OBJECT_ID          =>  p_object_id,
                                               p_OBJECT_ID2         =>  p_object_id2,
                                               p_OBJECT_TYPE_CODE   =>  p_object_type_code,
                                               p_SEQUENCE_NUM       =>  ln_new_seq_number,
                                               p_ACTION_TYPE        =>  p_action_type,
                                               p_ACTION_USER_ID     =>  p_action_user_id,
                                               p_ACTION_NOTE        =>  p_action_note,
                                               p_ACTION_REASON_CODE =>  p_action_reason_code);


                      -- Second with the future information
                             InsertRowHandler( p_OBJECT_ID          =>  p_object_id,
                                               p_OBJECT_ID2         =>  p_object_id2,
                                               p_OBJECT_TYPE_CODE   =>  p_object_type_code,
                                               p_SEQUENCE_NUM       =>  1,
                                               p_ACTION_TYPE        =>  NULL,
                                               p_ACTION_USER_ID     =>  p_action_user_id_next,
                                               p_ACTION_NOTE        =>  p_action_note,
                                               p_ACTION_REASON_CODE =>  p_action_reason_code);


                   else

                      -- since the sequence number is not 0 then we have a create a
                      -- single row and update the existing row


                             UpdateRowHandler( p_OBJECT_ID          =>  p_object_id,
                                               p_OBJECT_ID2         =>  p_object_id2,
                                               p_OBJECT_TYPE_CODE   =>  p_object_type_code,
                                               p_SEQUENCE_NUM       =>  ln_seq_number,
                                               p_ACTION_TYPE        =>  p_action_type);


                             InsertRowHandler( p_OBJECT_ID          =>  p_object_id,
                                               p_OBJECT_ID2         =>  p_object_id2,
                                               p_OBJECT_TYPE_CODE   =>  p_object_type_code,
                                               p_SEQUENCE_NUM       =>  ln_new_seq_number,
                                               p_ACTION_TYPE        =>  NULL,
                                               p_ACTION_USER_ID     =>  p_action_user_id_next,
                                               p_ACTION_NOTE        =>  p_action_note,
                                               p_ACTION_REASON_CODE =>  p_action_reason_code);


                   end if;

        END IF;

END RecordHistory;

END PON_ACTION_HIST_PKG;


/
