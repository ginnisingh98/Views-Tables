--------------------------------------------------------
--  DDL for Package Body EGO_POST_PROCESS_MESSAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_POST_PROCESS_MESSAGE_PVT" AS
/* $Header: EGOVPPMB.pls 120.6 2007/06/20 13:09:35 bbpatel noship $ */

  PROCEDURE  Get_Canonical_CIC_Multi
              (
                  p_version                     IN          VARCHAR2
                 ,p_entity_name                 IN          VARCHAR2
                 ,p_pk1_value                   IN          VARCHAR2
                 ,p_pk2_value                   IN          VARCHAR2
                 ,p_pk3_value                   IN          VARCHAR2
                 ,p_pk4_value                   IN          VARCHAR2
                 ,p_pk5_value                   IN          VARCHAR2
                , p_message_status              IN          VARCHAR2
                , p_language_code               IN          VARCHAR2
                , p_start_index                 IN          NUMBER
                , p_bundles_window_size         IN          NUMBER
                , p_last_update_date            IN          VARCHAR2
                , x_canonical_cic_payload       OUT NOCOPY  XMLTYPE
                , x_bundles_processed_count     OUT NOCOPY  NUMBER
                , x_remaining_bundles_count     OUT NOCOPY  NUMBER
                , x_return_status               OUT NOCOPY  VARCHAR2
                , x_msg_data                    OUT NOCOPY  VARCHAR2
              )
  IS

    l_header_tag                    XMLTYPE;
    l_item_response_tags            XMLTYPE;
    l_item_line_response_tag        XMLTYPE;
    l_item_line_response_tags       XMLTYPE;
    l_data_area_tags                XMLTYPE;
    l_confirmation_message_tag      XMLTYPE;
    l_language_code                 VARCHAR2(2);
    l_bundles_processed_count       NUMBER;
    l_remaining_bundles_count       NUMBER;
    l_current_message_id            EGO_UCCNET_EVENTS.MESSAGE_ID%TYPE;
    l_previous_message_id           EGO_UCCNET_EVENTS.MESSAGE_ID%TYPE;
    l_current_bundle_id             MTL_ITEM_BULKLOAD_RECS.BUNDLE_ID%TYPE;

    EGO_NO_BUNDLES_IN_COLLECTION    EXCEPTION;
    PRAGMA EXCEPTION_INIT( EGO_NO_BUNDLES_IN_COLLECTION, -20000 );

    CURSOR get_item_response_tags ( c_bundle_collection_id        NUMBER,
                                    c_bundle_id                   NUMBER,
                                    c_language_code               VARCHAR2 )
    IS
      SELECT
            XMLELEMENT( "ItemConfirmation",
                          XMLELEMENT( "ItemIdentification",
                                        XMLELEMENT( "EBOID" ),
                                        XMLELEMENT( "GTIN",
                                                    ( SELECT  eue.GTIN
                                                      FROM    EGO_UCCNET_EVENTS eue
                                                      WHERE   eue.CLN_ID = euaci.CLN_ID
                                                      AND     eue.SOURCE_SYSTEM_ID = euaci.SOURCE_SYSTEM_ID
                                                      AND     eue.SOURCE_SYSTEM_REFERENCE = euaci.SOURCE_SYSTEM_REFERENCE )
                                                  )
                                    ),
                          XMLELEMENT( "ProcessingError",
                                        XMLELEMENT( "Problem",
                                                      XMLELEMENT( "Code", euaci.CODE ),
                                                      XMLELEMENT( "Description", XMLATTRIBUTES( c_language_code AS "languageID" ),
                                                                  status_lkup.DESCRIPTION
                                                                ),
                                                      DECODE (  euaci.DESCRIPTION,
                                                                NULL, NULL,
                                                                XMLELEMENT( "Note", XMLATTRIBUTES( c_language_code AS "languageID" ),
                                                                            euaci.DESCRIPTION
                                                                          )
                                                             )
                                                  ),
                                        DECODE  ( euaci.ACTION_NEEDED,
                                                  NULL, NULL,
                                                  XMLELEMENT( "Resolution",
                                                                XMLELEMENT( "Code", euaci.ACTION_NEEDED ),
                                                                XMLELEMENT( "Description", XMLATTRIBUTES( c_language_code AS "languageID" ),
                                                                            corrective_action_lkup.DESCRIPTION
                                                                          )
                                                            )
                                                )
                                    )
                      ) AS ITEM_RESPONSE_TAG
      FROM
          FND_LOOKUP_VALUES corrective_action_lkup,
          FND_LOOKUP_VALUES status_lkup,
          EGO_UCCNET_ADD_CIC_INFO euaci,
          MTL_ITEM_BULKLOAD_RECS mibr
      WHERE
          corrective_action_lkup.LANGUAGE (+) = c_language_code
      AND corrective_action_lkup.ENABLED_FLAG (+) = 'Y'
      AND ( corrective_action_lkup.END_DATE_ACTIVE IS NULL OR corrective_action_lkup.END_DATE_ACTIVE > SYSDATE )
      AND corrective_action_lkup.LOOKUP_CODE (+) = euaci.ACTION_NEEDED
      AND corrective_action_lkup.LOOKUP_TYPE (+) = 'EGO_ORCH_CORR_ACTION_CODE'
      AND status_lkup.LANGUAGE = c_language_code
      AND status_lkup.ENABLED_FLAG = 'Y'
      AND ( status_lkup.END_DATE_ACTIVE IS NULL OR status_lkup.END_DATE_ACTIVE > SYSDATE )
      AND status_lkup.LOOKUP_CODE = euaci.CODE
      AND status_lkup.LOOKUP_TYPE = 'EGO_ORCH_STATUS_CODE'
      AND euaci.LAST_UPDATE_DATE = TO_DATE ( p_last_update_date, EGO_POST_PROCESS_MESSAGE_PVT.G_DATE_FORMAT )
      AND ( euaci.CODE IS NOT NULL )
      AND euaci.MESSAGE_SENT_FLAG = 'N'
      AND euaci.SOURCE_SYSTEM_REFERENCE = mibr.SOURCE_SYSTEM_REFERENCE
      AND euaci.SOURCE_SYSTEM_ID = mibr.SOURCE_SYSTEM_ID
      AND euaci.CLN_ID = mibr.BUNDLE_ID
      AND mibr.BUNDLE_ID = c_bundle_id
      AND mibr.BUNDLE_COLLECTION_ID = c_bundle_collection_id;

    CURSOR get_item_line_response_tag ( c_bundle_id             NUMBER,
                                        c_message_status        VARCHAR2,
                                        c_item_response_tags    XMLTYPE )
    IS
      SELECT
            XMLELEMENT( "ItemPublicationLineConfirmation",
                          XMLELEMENT( "ItemPublicationLineIdentification",
                                        XMLELEMENT( "EBOID" ),
                                        XMLELEMENT( "AlternateIdentification" ,
                                                      XMLELEMENT( "ID" , eue.EXT_COMPLEX_ITEM_REFERENCE )
                                                  )
                                    ),
                          XMLELEMENT( "ProcessingStatus",
                                        XMLELEMENT( "Code", c_message_status )
                                    ),
                          c_item_response_tags
                      ) AS ITEM_LINE_RESPONSE_TAG
      FROM  EGO_UCCNET_EVENTS eue
      WHERE
            eue.CLN_ID = c_bundle_id
      AND   ROWNUM = 1;

    CURSOR get_bundles_in_collection  (   c_bundle_collection_id  NUMBER
                                        , c_start_index           NUMBER
                                        , c_bundles_window_size   NUMBER )
    IS
      SELECT *
      FROM
         (  SELECT  ROWNUM RN,
                    MESSAGE_ID,
                    BUNDLE_ID
            FROM
                ( SELECT  eue.MESSAGE_ID MESSAGE_ID,
                          mibr.BUNDLE_ID BUNDLE_ID
                  FROM    EGO_UCCNET_EVENTS eue,
                          MTL_ITEM_BULKLOAD_RECS mibr
                  WHERE
                        eue.CLN_ID = mibr.BUNDLE_ID
                  AND   mibr.BUNDLE_COLLECTION_ID = c_bundle_collection_id
                  GROUP BY eue.MESSAGE_ID, mibr.BUNDLE_ID
                  ORDER BY eue.MESSAGE_ID, mibr.BUNDLE_ID )
            WHERE ROWNUM < ( c_start_index + c_bundles_window_size ) )
      WHERE RN BETWEEN c_start_index AND ( c_start_index + c_bundles_window_size - 1 );

  BEGIN

    IF (  p_entity_name = 'RECORD_COLLECTION' )
    THEN

      -- create the header element
      SELECT
        XMLELEMENT( "EBMHeader",
                      XMLELEMENT( "VerbCode" ),
                      XMLELEMENT( "Sender",
                                    XMLELEMENT( "ID" )
                                )
                  )
      INTO l_header_tag
      FROM DUAL;

      l_language_code := p_language_code;
      l_bundles_processed_count := 0;
      l_data_area_tags := NULL;
      l_current_message_id := '-9999';
      l_previous_message_id := '-9999';
      l_confirmation_message_tag := NULL;
      l_remaining_bundles_count := 0;

      -- for all bundles create data area tag
      FOR l_bundle_rec IN get_bundles_in_collection ( TO_NUMBER ( p_pk1_value )
                                                    , p_start_index
                                                    , p_bundles_window_size )
      LOOP

        l_bundles_processed_count := l_bundles_processed_count + 1;
        l_item_response_tags := NULL;
        l_current_message_id := l_bundle_rec.message_id;
        l_current_bundle_id := l_bundle_rec.bundle_id;

        -- Do not append status information for Synchronized message.
        IF ( p_message_status <> EGO_POST_PROCESS_MESSAGE_PVT.G_CIC_SYNC_MESSAGE_TYPE )
        THEN

          -- Create item level response tags.
          FOR l_item_response_tag_rec IN get_item_response_tags (   TO_NUMBER ( p_pk1_value )
                                                                  , l_bundle_rec.bundle_id
                                                                  , l_language_code )
          LOOP
            SELECT  XMLCONCAT( l_item_response_tags, l_item_response_tag_rec.item_response_tag )
            INTO    l_item_response_tags
            FROM DUAL;
          END LOOP;

        END IF;

        -- Create item line publication response tag.
        FOR l_item_line_response_tag_rec IN get_item_line_response_tag (  l_current_bundle_id
                                                                        , p_message_status
                                                                        , l_item_response_tags )
        LOOP
          l_item_line_response_tag := l_item_line_response_tag_rec.item_line_response_tag;
        END LOOP;

        --message id change logic
        IF ( ( l_current_message_id = l_previous_message_id ) OR ( l_previous_message_id = '-9999' ) )
        THEN

          -- Same message id bundle
          SELECT  XMLCONCAT( l_item_line_response_tags, l_item_line_response_tag )
          INTO    l_item_line_response_tags
          FROM DUAL;

        ELSE

          -- Bundle id belonging to different message id
          -- create a data area tag
          SELECT
                XMLCONCAT ( XMLELEMENT( "DataArea",
                                            XMLELEMENT( "Sync" ),
                                            XMLELEMENT( "SyncItemPublicationConfirmation",
                                                          XMLELEMENT( "ItemPublicationIdentification",
                                                                        XMLELEMENT( "EBOID" ),
                                                                        XMLELEMENT( "AlternateIdentification" ,
                                                                                      XMLELEMENT( "ID" , l_previous_message_id )
                                                                                  )
                                                                    ),
                                                          l_item_line_response_tags
                                                      )
                                      ),
                            l_data_area_tags
                          )
          INTO  l_data_area_tags
          FROM  DUAL;

          -- initialize item line response tags for new message that will belong to new data area
          l_item_line_response_tags := NULL;
          SELECT  XMLCONCAT( l_item_line_response_tags, l_item_line_response_tag )
          INTO    l_item_line_response_tags
          FROM DUAL;

        END IF;

        l_previous_message_id := l_current_message_id;

      END LOOP;

      IF ( l_bundles_processed_count = 0 )
      THEN

        -- No bundles in collection, raise exception
        RAISE EGO_NO_BUNDLES_IN_COLLECTION;

      ELSE

        -- append the last data area tag
        SELECT
              XMLCONCAT ( XMLELEMENT( "DataArea",
                                          XMLELEMENT( "Sync" ),
                                          XMLELEMENT( "SyncItemPublicationConfirmation",
                                                        XMLELEMENT( "ItemPublicationIdentification",
                                                                      XMLELEMENT( "EBOID" ),
                                                                      XMLELEMENT( "AlternateIdentification" ,
                                                                                    XMLELEMENT( "ID" , l_previous_message_id )
                                                                                )
                                                                  ),
                                                        l_item_line_response_tags
                                                    )
                                    ),
                          l_data_area_tags
                        )
        INTO  l_data_area_tags
        FROM  DUAL;

        -- Create confirmation message tag
        SELECT
              XMLELEMENT( "SyncItemPublicationConfirmationEBM",
                              l_header_tag,
                              l_data_area_tags
                        )
        INTO  l_confirmation_message_tag
        FROM
            DUAL;

        -- update the remaining bundles in collection count.
        SELECT  COUNT(1)
        INTO    l_remaining_bundles_count
        FROM
           (  SELECT  ROWNUM RN,
                      MESSAGE_ID,
                      BUNDLE_ID
              FROM
                  ( SELECT  eue.MESSAGE_ID MESSAGE_ID,
                            mibr.BUNDLE_ID BUNDLE_ID
                    FROM    EGO_UCCNET_EVENTS eue,
                            MTL_ITEM_BULKLOAD_RECS mibr
                    WHERE
                          eue.CLN_ID = mibr.BUNDLE_ID
                    AND   mibr.BUNDLE_COLLECTION_ID = TO_NUMBER ( p_pk1_value )
                    GROUP BY eue.MESSAGE_ID, mibr.BUNDLE_ID
                    ORDER BY eue.MESSAGE_ID, mibr.BUNDLE_ID ) )
        WHERE RN >= ( p_start_index + p_bundles_window_size );

      END IF; -- end IF ( l_bundles_processed_count = 0 )

      x_canonical_cic_payload := l_confirmation_message_tag;
      x_bundles_processed_count := l_bundles_processed_count;
      x_remaining_bundles_count := l_remaining_bundles_count;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_msg_data := NULL;

    END IF;

  EXCEPTION

    WHEN EGO_NO_BUNDLES_IN_COLLECTION THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name ( 'EGO', 'EGO_NO_BUNDLES_IN_COLLECTION' );
      FND_MESSAGE.Set_Token ( 'BUNDLE_COLLECTION_ID', p_pk1_value );
      x_msg_data := FND_MESSAGE.Get;

      -- set null values for output params
      x_canonical_cic_payload := NULL;
      x_bundles_processed_count := 0;
      x_remaining_bundles_count := 0;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := SQLERRM;

  END Get_Canonical_CIC_Multi;

  PROCEDURE  Update_Message_Sent_Info_Multi
              (
                  p_version                     IN          VARCHAR2
                 ,p_entity_name                 IN          VARCHAR2
                 ,p_pk1_value                   IN          VARCHAR2
                 ,p_pk2_value                   IN          VARCHAR2
                 ,p_pk3_value                   IN          VARCHAR2
                 ,p_pk4_value                   IN          VARCHAR2
                 ,p_pk5_value                   IN          VARCHAR2
                , p_message_status              IN          VARCHAR2
                , p_start_index                 IN          NUMBER
                , p_bundles_window_size         IN          NUMBER
                , p_commit_flag                 IN          VARCHAR2
                , p_last_update_date            IN          VARCHAR2
                , x_return_status               OUT NOCOPY  VARCHAR2
                , x_msg_data                    OUT NOCOPY  VARCHAR2
              )
  IS

    l_sysdate                     DATE;

  BEGIN

    SELECT  SYSDATE
    INTO    l_sysdate
    FROM    DUAL;

    -- For Reject and Synchronized message, update the message sent info for entire hierarchy.
    -- Not updating the last update date otherwise it can bring inconsistency between message type
    -- in EVENTS table and max last update date row ADD_CIC_INFO table.

    IF ( p_message_status IN (  EGO_POST_PROCESS_MESSAGE_PVT.G_CIC_SYNC_MESSAGE_TYPE
                              , EGO_POST_PROCESS_MESSAGE_PVT.G_CIC_REJECTED_MESSAGE_TYPE ) )
    THEN

      UPDATE  EGO_UCCNET_EVENTS
      SET     DISPOSITION_DATE = l_sysdate
      WHERE   ( CLN_ID ) IN
                  ( SELECT mibr.BUNDLE_ID
                    FROM
                       (  SELECT  ROWNUM RN,
                                  MESSAGE_ID,
                                  BUNDLE_ID
                          FROM
                              ( SELECT  eue.MESSAGE_ID MESSAGE_ID,
                                        mibr.BUNDLE_ID BUNDLE_ID
                                FROM    EGO_UCCNET_EVENTS eue,
                                        MTL_ITEM_BULKLOAD_RECS mibr
                                WHERE
                                      eue.CLN_ID = mibr.BUNDLE_ID
                                AND   mibr.BUNDLE_COLLECTION_ID = TO_NUMBER ( p_pk1_value )
                                GROUP BY eue.MESSAGE_ID, mibr.BUNDLE_ID
                                ORDER BY eue.MESSAGE_ID, mibr.BUNDLE_ID )
                          WHERE ROWNUM < ( p_start_index + p_bundles_window_size ) ) selected_bundles,
                          MTL_ITEM_BULKLOAD_RECS mibr
                    WHERE
                            mibr.BUNDLE_ID = selected_bundles.BUNDLE_ID
                    AND     selected_bundles.RN BETWEEN p_start_index AND ( p_start_index + p_bundles_window_size - 1 )
                    AND     mibr.BUNDLE_COLLECTION_ID = TO_NUMBER ( p_pk1_value ) );

      UPDATE  EGO_UCCNET_ADD_CIC_INFO
      SET     MESSAGE_SENT_FLAG = 'Y'
      WHERE   MESSAGE_SENT_FLAG = 'N'
      AND     LAST_UPDATE_DATE = TO_DATE ( p_last_update_date, EGO_POST_PROCESS_MESSAGE_PVT.G_DATE_FORMAT )
      AND     ( CLN_ID ) IN
                        ( SELECT mibr_outer.BUNDLE_ID
                          FROM
                             (  SELECT  ROWNUM RN,
                                        MESSAGE_ID,
                                        BUNDLE_ID
                                FROM
                                    ( SELECT  eue.MESSAGE_ID MESSAGE_ID,
                                              mibr.BUNDLE_ID BUNDLE_ID
                                      FROM    EGO_UCCNET_EVENTS eue,
                                              MTL_ITEM_BULKLOAD_RECS mibr
                                      WHERE
                                            eue.CLN_ID = mibr.BUNDLE_ID
                                      AND   mibr.BUNDLE_COLLECTION_ID = TO_NUMBER ( p_pk1_value )
                                      GROUP BY eue.MESSAGE_ID, mibr.BUNDLE_ID
                                      ORDER BY eue.MESSAGE_ID, mibr.BUNDLE_ID )
                                WHERE ROWNUM < ( p_start_index + p_bundles_window_size ) ) selected_bundles,
                            MTL_ITEM_BULKLOAD_RECS mibr_outer
                          WHERE
                                  mibr_outer.BUNDLE_ID = selected_bundles.BUNDLE_ID
                          AND     selected_bundles.RN BETWEEN p_start_index AND ( p_start_index + p_bundles_window_size - 1 )
                          AND     mibr_outer.BUNDLE_COLLECTION_ID = TO_NUMBER ( p_pk1_value ) );

    ELSIF ( p_message_status = EGO_POST_PROCESS_MESSAGE_PVT.G_CIC_REVIEW_MESSAGE_TYPE )
    THEN

      UPDATE  EGO_UCCNET_EVENTS
      SET     DISPOSITION_DATE = l_sysdate
      WHERE   ( CLN_ID, SOURCE_SYSTEM_ID, SOURCE_SYSTEM_REFERENCE ) IN
                  ( SELECT mibr.BUNDLE_ID, mibr.SOURCE_SYSTEM_ID, mibr.SOURCE_SYSTEM_REFERENCE
                    FROM
                       (  SELECT  ROWNUM RN,
                                  MESSAGE_ID,
                                  BUNDLE_ID
                          FROM
                              ( SELECT  eue.MESSAGE_ID MESSAGE_ID,
                                        mibr.BUNDLE_ID BUNDLE_ID
                                FROM    EGO_UCCNET_EVENTS eue,
                                        MTL_ITEM_BULKLOAD_RECS mibr
                                WHERE
                                      eue.CLN_ID = mibr.BUNDLE_ID
                                AND   mibr.BUNDLE_COLLECTION_ID = TO_NUMBER ( p_pk1_value )
                                GROUP BY eue.MESSAGE_ID, mibr.BUNDLE_ID
                                ORDER BY eue.MESSAGE_ID, mibr.BUNDLE_ID )
                          WHERE ROWNUM < ( p_start_index + p_bundles_window_size ) ) selected_bundles,
                          MTL_ITEM_BULKLOAD_RECS mibr
                    WHERE
                            mibr.BUNDLE_ID = selected_bundles.BUNDLE_ID
                    AND     selected_bundles.RN BETWEEN p_start_index AND ( p_start_index + p_bundles_window_size - 1 )
                    AND     mibr.BUNDLE_COLLECTION_ID = TO_NUMBER ( p_pk1_value ) );

      UPDATE  EGO_UCCNET_ADD_CIC_INFO
      SET     MESSAGE_SENT_FLAG = 'Y'
      WHERE   MESSAGE_SENT_FLAG = 'N'
      AND     LAST_UPDATE_DATE = TO_DATE ( p_last_update_date, EGO_POST_PROCESS_MESSAGE_PVT.G_DATE_FORMAT )
      AND     ( CLN_ID, SOURCE_SYSTEM_ID, SOURCE_SYSTEM_REFERENCE ) IN
                        ( SELECT mibr_outer.BUNDLE_ID, mibr_outer.SOURCE_SYSTEM_ID, mibr_outer.SOURCE_SYSTEM_REFERENCE
                          FROM
                             (  SELECT  ROWNUM RN,
                                        MESSAGE_ID,
                                        BUNDLE_ID
                                FROM
                                    ( SELECT  eue.MESSAGE_ID MESSAGE_ID,
                                              mibr.BUNDLE_ID BUNDLE_ID
                                      FROM    EGO_UCCNET_EVENTS eue,
                                              MTL_ITEM_BULKLOAD_RECS mibr
                                      WHERE
                                            eue.CLN_ID = mibr.BUNDLE_ID
                                      AND   mibr.BUNDLE_COLLECTION_ID = TO_NUMBER ( p_pk1_value )
                                      GROUP BY eue.MESSAGE_ID, mibr.BUNDLE_ID
                                      ORDER BY eue.MESSAGE_ID, mibr.BUNDLE_ID )
                                WHERE ROWNUM < ( p_start_index + p_bundles_window_size ) ) selected_bundles,
                            MTL_ITEM_BULKLOAD_RECS mibr_outer
                          WHERE
                                  mibr_outer.BUNDLE_ID = selected_bundles.BUNDLE_ID
                          AND     selected_bundles.RN BETWEEN p_start_index AND ( p_start_index + p_bundles_window_size - 1 )
                          AND     mibr_outer.BUNDLE_COLLECTION_ID = TO_NUMBER ( p_pk1_value ) );

    END IF;

    IF ( p_commit_flag = 'Y' ) THEN
      COMMIT;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_data := NULL;

  EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := SQLERRM;

  END Update_Message_Sent_Info_Multi;

  PROCEDURE  Update_Corrective_Info
              (
                  p_bundle_id_tbl               IN          EGO_VARCHAR_TBL_TYPE
                , p_source_system_id_tbl        IN          EGO_VARCHAR_TBL_TYPE
                , p_source_system_ref_tbl       IN          EGO_VARCHAR_TBL_TYPE
                , p_message_type_code           IN          VARCHAR2
                , p_status_code                 IN          VARCHAR2
                , p_corrective_action_code      IN          VARCHAR2
                , p_additional_info             IN          VARCHAR2
                , p_last_update_date            IN          VARCHAR2
                , x_last_update_date            OUT NOCOPY  VARCHAR2
                , x_return_status               OUT NOCOPY  VARCHAR2
                , x_msg_data                    OUT NOCOPY  VARCHAR2
              )
  IS

    l_last_update_login       NUMBER;
    l_last_updated_by         NUMBER;
    l_sysdate                 DATE;
    l_last_update_date        VARCHAR2(50);

  BEGIN

    l_last_update_login := FND_GLOBAL.LOGIN_ID;
    l_last_updated_by := FND_GLOBAL.USER_ID;

    -- If null then take the sysdate
    IF ( p_last_update_date IS NULL )
    THEN

      SELECT  SYSDATE, TO_CHAR ( SYSDATE, EGO_POST_PROCESS_MESSAGE_PVT.G_DATE_FORMAT )
      INTO    l_sysdate, l_last_update_date
      FROM    DUAL;

    ELSE

      l_sysdate := TO_DATE ( p_last_update_date, EGO_POST_PROCESS_MESSAGE_PVT.G_DATE_FORMAT );
      l_last_update_date := p_last_update_date;

    END IF;

    -- For Accepted, Reject and Synchronized message, update the entire hierarchy.
    -- Also insert the rows for all items in the bundle into cic_info table

    IF ( p_message_type_code IN (   EGO_POST_PROCESS_MESSAGE_PVT.G_CIC_SYNC_MESSAGE_TYPE
                                  , EGO_POST_PROCESS_MESSAGE_PVT.G_CIC_REJECTED_MESSAGE_TYPE
                                  , EGO_POST_PROCESS_MESSAGE_PVT.G_CIC_ACCEPTED_MESSAGE_TYPE ) )
    THEN

      FOR i IN p_bundle_id_tbl.FIRST .. p_bundle_id_tbl.LAST
      LOOP

        -- Update all the items in the bundle
        UPDATE  EGO_UCCNET_EVENTS
        SET     DISPOSITION_CODE = p_message_type_code
              , LAST_UPDATED_BY = l_last_updated_by
              , LAST_UPDATE_DATE = l_sysdate
              , LAST_UPDATE_LOGIN = l_last_update_login
        WHERE
              CLN_ID = TO_NUMBER( p_bundle_id_tbl(i) ) ;

        -- insert the rows for all the items in the bundle with given corrective info
        INSERT INTO EGO_UCCNET_ADD_CIC_INFO
          (
              CLN_ID
            , SOURCE_SYSTEM_ID
            , SOURCE_SYSTEM_REFERENCE
            , CODE
            , DESCRIPTION
            , ACTION_NEEDED
            , MESSAGE_SENT_FLAG
            , CREATED_BY
            , CREATION_DATE
            , LAST_UPDATED_BY
            , LAST_UPDATE_DATE
            , LAST_UPDATE_LOGIN
          )
          SELECT
                  CLN_ID
                , SOURCE_SYSTEM_ID
                , SOURCE_SYSTEM_REFERENCE
                , p_status_code
                , p_additional_info
                , p_corrective_action_code
                , 'N'
                , l_last_updated_by
                , l_sysdate
                , l_last_updated_by
                , l_sysdate
                , l_last_update_login
          FROM    EGO_UCCNET_EVENTS
          WHERE
                CLN_ID = TO_NUMBER( p_bundle_id_tbl(i) ) ;

      END LOOP;

    ELSIF ( p_message_type_code = EGO_POST_PROCESS_MESSAGE_PVT.G_CIC_REVIEW_MESSAGE_TYPE )
    THEN

      FOR i IN p_bundle_id_tbl.FIRST .. p_bundle_id_tbl.LAST
      LOOP

        UPDATE  EGO_UCCNET_EVENTS
        SET     DISPOSITION_CODE = p_message_type_code
              , LAST_UPDATED_BY = l_last_updated_by
              , LAST_UPDATE_DATE = l_sysdate
              , LAST_UPDATE_LOGIN = l_last_update_login
        WHERE
                SOURCE_SYSTEM_REFERENCE = p_source_system_ref_tbl(i)
        AND     SOURCE_SYSTEM_ID = TO_NUMBER( p_source_system_id_tbl(i) )
        AND     CLN_ID = TO_NUMBER( p_bundle_id_tbl(i) );

        INSERT INTO EGO_UCCNET_ADD_CIC_INFO
          (
              CLN_ID
            , SOURCE_SYSTEM_ID
            , SOURCE_SYSTEM_REFERENCE
            , CODE
            , DESCRIPTION
            , ACTION_NEEDED
            , MESSAGE_SENT_FLAG
            , CREATED_BY
            , CREATION_DATE
            , LAST_UPDATED_BY
            , LAST_UPDATE_DATE
            , LAST_UPDATE_LOGIN
          )
        VALUES
          (
              TO_NUMBER( p_bundle_id_tbl(i) )
            , TO_NUMBER( p_source_system_id_tbl(i) )
            , p_source_system_ref_tbl(i)
            , p_status_code
            , p_additional_info
            , p_corrective_action_code
            , 'N'
            , l_last_updated_by
            , l_sysdate
            , l_last_updated_by
            , l_sysdate
            , l_last_update_login
          );

      END LOOP;

    END IF;

    x_last_update_date := l_last_update_date;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_data := NULL;

  EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := SQLERRM;

  END Update_Corrective_Info;

  PROCEDURE  Send_Sync_Msg_On_Batch_Import
              (
                  p_batch_id                    IN          NUMBER
                , p_request_id                  IN          NUMBER
                , p_commit_flag                 IN          VARCHAR2
                , x_return_status               OUT NOCOPY  VARCHAR2
                , x_msg_data                    OUT NOCOPY  VARCHAR2
              )
  IS

    l_bundle_id_tbl           EGO_VARCHAR_TBL_TYPE;
    l_source_system_id_tbl    EGO_VARCHAR_TBL_TYPE;
    l_source_system_ref_tbl   EGO_VARCHAR_TBL_TYPE;
    l_item_bundle_tags        XMLTYPE;
    l_item_bundles_tag        XMLTYPE;
    l_return_status           VARCHAR2(100);
    l_msg_data                VARCHAR2(4000);
    l_last_update_date        VARCHAR2(50);
    l_bundle_collection_id    NUMBER;
    l_total_bundles           NUMBER;
    l_send_message_flag       BOOLEAN;

    CURSOR get_data_pool_enabled ( c_batch_id                    NUMBER )
    IS
      SELECT  NVL ( eios.ENABLED_FOR_DATA_POOL, 'N' ) AS ENABLED_FOR_DATA_POOL
      FROM    EGO_IMPORT_OPTION_SETS eios
      WHERE   eios.BATCH_ID = c_batch_id;

    CURSOR get_sucessful_bundles_top_item (   c_batch_id                    NUMBER
                                            , c_request_id                  NUMBER )
    IS
      SELECT  msii.BUNDLE_ID, msii.SOURCE_SYSTEM_ID, msii.SOURCE_SYSTEM_REFERENCE
      FROM    MTL_SYSTEM_ITEMS_INTERFACE msii,
              ( SELECT  DISTINCT msii_inner1.BUNDLE_ID BUNDLE_ID
                FROM    MTL_SYSTEM_ITEMS_INTERFACE msii_inner1
                WHERE   msii_inner1.REQUEST_ID = c_request_id
                AND     msii_inner1.SET_PROCESS_ID = c_batch_id
              ) selected_bundles
      WHERE
              'S' = COALESCE  (
                                ( SELECT  'F'
                                  FROM    MTL_SYSTEM_ITEMS_INTERFACE msii_inner2
                                  WHERE
                                          msii_inner2.PROCESS_FLAG <> 7
                                  AND     msii_inner2.BUNDLE_ID = selected_bundles.BUNDLE_ID
                                  AND     msii_inner2.SET_PROCESS_ID = c_batch_id
                                  AND     ROWNUM = 1 )
                               ,( SELECT  'F'
                                  FROM    EGO_ITM_USR_ATTR_INTRFC eiuai
                                  WHERE
                                          ( ( eiuai.PROCESS_STATUS <> 4 ) AND ( eiuai.PROCESS_STATUS <> 7 ) )
                                  AND     eiuai.BUNDLE_ID = selected_bundles.BUNDLE_ID
                                  AND     eiuai.DATA_SET_ID = c_batch_id
                                  AND     ROWNUM = 1 )
                               ,( SELECT  'F'
                                  FROM    EGO_ITEM_ASSOCIATIONS_INTF eiai
                                  WHERE
                                          eiai.PROCESS_FLAG <> 7
                                  AND     eiai.BUNDLE_ID = selected_bundles.BUNDLE_ID
                                  AND     eiai.BATCH_ID = c_batch_id
                                  AND     ROWNUM = 1 )
                               ,( SELECT  'F'
                                  FROM    MTL_ITEM_CATEGORIES_INTERFACE mici
                                  WHERE
                                          mici.PROCESS_FLAG <> 7
                                  AND     mici.BUNDLE_ID = selected_bundles.BUNDLE_ID
                                  AND     mici.SET_PROCESS_ID = c_batch_id
                                  AND     ROWNUM = 1 )
                               ,( SELECT  'F'
                                  FROM    BOM_BILL_OF_MTLS_INTERFACE bbmi
                                  WHERE
                                          bbmi.PROCESS_FLAG <> 7
                                  AND     bbmi.BUNDLE_ID = selected_bundles.BUNDLE_ID
                                  AND     bbmi.BATCH_ID = c_batch_id
                                  AND     ROWNUM = 1 )
                               ,( SELECT  'F'
                                  FROM    BOM_INVENTORY_COMPS_INTERFACE bici
                                  WHERE
                                          bici.PROCESS_FLAG <> 7
                                  AND     bici.BUNDLE_ID = selected_bundles.BUNDLE_ID
                                  AND     bici.BATCH_ID = c_batch_id
                                  AND     ROWNUM = 1 )
                               /* -- Not checking the TL table as PROCESS_STATUS is not updated by import
                               ,( SELECT  'F'
                                  FROM    EGO_INTERFACE_TL eit
                                  WHERE
                                          eit.PROCESS_STATUS <> 7
                                  AND     eit.BUNDLE_ID = selected_bundles.BUNDLE_ID
                                  AND     eit.SET_PROCESS_ID = c_batch_id
                                  AND     ROWNUM = 1 )
                                */
                               ,( SELECT  'S'
                                  FROM    DUAL )
                              )
      AND     msii.TOP_ITEM_FLAG = 'Y'
      AND     msii.BUNDLE_ID = selected_bundles.BUNDLE_ID
      AND     msii.SET_PROCESS_ID = c_batch_id;

  BEGIN

    -- initialize local variables
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    l_msg_data := NULL;
    l_last_update_date := NULL;
    l_item_bundles_tag := NULL;
    l_item_bundle_tags := NULL;
    l_bundle_id_tbl := EGO_VARCHAR_TBL_TYPE();
    l_source_system_id_tbl := EGO_VARCHAR_TBL_TYPE();
    l_source_system_ref_tbl := EGO_VARCHAR_TBL_TYPE();
    l_total_bundles := 0;
    l_send_message_flag := FALSE;

    -- check for data pool GDSN enabled
    FOR l_data_pool_enabled_rec IN get_data_pool_enabled ( p_batch_id )
    LOOP

      IF ( l_data_pool_enabled_rec.enabled_for_data_pool = 'Y' )
      THEN
        l_send_message_flag := TRUE;
      END IF;

    END LOOP; -- end FOR l_data_pool_enabled_rec

    -- send sync message only if batch is GDSN enabled
    IF ( l_send_message_flag = TRUE )
    THEN
      -- loop to fetch 500 items at a time due to limit on EGO_VARCHAR_TBL_TYPE
      LOOP

        -- clear the tables
        l_bundle_id_tbl.DELETE;
        l_source_system_id_tbl.DELETE;
        l_source_system_ref_tbl.DELETE;

        -- open the successful top items cursor
        IF ( NOT get_sucessful_bundles_top_item%ISOPEN )
        THEN

          OPEN get_sucessful_bundles_top_item ( p_batch_id, p_request_id  );

        END IF;

        -- bulk fetch
        FETCH get_sucessful_bundles_top_item
        BULK COLLECT INTO
            l_bundle_id_tbl
          , l_source_system_id_tbl
          , l_source_system_ref_tbl
        LIMIT 500; -- 500 is limit because EGO_VARCHAR_TBL_TYPE has max 500 elements.

        EXIT WHEN l_bundle_id_tbl.COUNT = 0;

        l_total_bundles := l_total_bundles + l_bundle_id_tbl.COUNT;

        -- add the status and corrective info
        EGO_POST_PROCESS_MESSAGE_PVT.Update_Corrective_Info(
                                                             p_bundle_id_tbl            => l_bundle_id_tbl,
                                                             p_source_system_id_tbl     => l_source_system_id_tbl,
                                                             p_source_system_ref_tbl    => l_source_system_ref_tbl,
                                                             p_message_type_code        => EGO_POST_PROCESS_MESSAGE_PVT.G_CIC_SYNC_MESSAGE_TYPE,
                                                             p_status_code              => NULL,
                                                             p_corrective_action_code   => NULL,
                                                             p_additional_info          => NULL,
                                                             p_last_update_date         => l_last_update_date,
                                                             x_last_update_date         => l_last_update_date,
                                                             x_return_status            => l_return_status,
                                                             x_msg_data                 => l_msg_data
                                                           );


        IF ( l_return_status = FND_API.G_RET_STS_SUCCESS )
        THEN

          -- create ItemBundle tags
          FOR i IN l_bundle_id_tbl.FIRST .. l_bundle_id_tbl.LAST
          LOOP

            SELECT  XMLCONCAT ( l_item_bundle_tags,
                                XMLELEMENT ( "ItemBundle",
                                                XMLELEMENT ( "BundleId", l_bundle_id_tbl(i) ),
                                                XMLELEMENT ( "ItemSourceSystemId", l_source_system_id_tbl(i) ),
                                                XMLELEMENT ( "ItemSourceSystemReference", l_source_system_ref_tbl(i) )
                                          )
                              )
            INTO    l_item_bundle_tags
            FROM    DUAL;

          END LOOP; -- end FOR i IN l_bundle_id_tbl

        ELSE

          -- exit on errored return status
          EXIT;

        END IF; -- end IF ( l_return_status

      END LOOP; -- end loop to fetch 500 items

      -- close the cursor
      IF ( get_sucessful_bundles_top_item%ISOPEN )
      THEN

        CLOSE get_sucessful_bundles_top_item;

      END IF;

      IF ( l_total_bundles > 0 )
      THEN

        -- create record collection over bundles
        IF ( l_return_status = FND_API.G_RET_STS_SUCCESS )
        THEN

          -- create top level ItemBundles tag
          SELECT  XMLELEMENT ( "ItemBundles",
                                  l_item_bundle_tags
                             )
          INTO    l_item_bundles_tag
          FROM    DUAL;

          -- create collection over successful top items
          EGO_ORCHESTRATION_UTIL_PUB.ADD_BUNDLES_TO_COL(
                                                         x_bundle_collection_id             => -1,
                                                         p_bundles_clob                     => TO_CLOB ( l_item_bundles_tag.getStringVal() ),
                                                         p_commit                           => 'N', -- commit will be done at the end
                                                         p_entity_name                      => 'ITEM',
                                                         x_new_bundle_col_id                =>  l_bundle_collection_id
                                                        );

        END IF; -- end IF ( l_return_status

        IF ( l_return_status = FND_API.G_RET_STS_SUCCESS )
        THEN
          -- raise the post process message business event
          EGO_WF_WRAPPER_PVT.Raise_Post_Process_Msg_Event(
                                                          p_event_name       => EGO_WF_WRAPPER_PVT.G_POST_PROCESS_MESSAGE_EVENT,
                                                          p_entity_name      => 'RECORD_COLLECTION',
                                                          p_pk1_value        => l_bundle_collection_id,
                                                          p_pk2_value        => NULL,
                                                          p_pk3_value        => NULL,
                                                          p_pk4_value        => NULL,
                                                          p_pk5_value        => NULL,
                                                          p_processing_type  => EGO_POST_PROCESS_MESSAGE_PVT.G_CIC_SYNC_MESSAGE_TYPE,
                                                          p_language_code    => USERENV('LANG'),
                                                          p_last_update_date => l_last_update_date,
                                                          x_msg_data         => l_msg_data,
                                                          x_return_status    => l_return_status
                                                         );
        END IF; -- end IF ( l_return_status

        -- commit depending on flag
        IF ( ( l_return_status = FND_API.G_RET_STS_SUCCESS ) AND ( p_commit_flag = 'Y' ) )
        THEN
          COMMIT;
        END IF;

      END IF; -- end if ( l_total_bundles > 0 )

    END IF; -- end IF ( l_send_message_flag

    x_return_status := l_return_status;
    x_msg_data := l_msg_data;

  EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := SQLERRM;

  END Send_Sync_Msg_On_Batch_Import;

END EGO_POST_PROCESS_MESSAGE_PVT;

/
