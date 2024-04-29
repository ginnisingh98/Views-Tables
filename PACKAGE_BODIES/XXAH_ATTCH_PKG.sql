--------------------------------------------------------
--  DDL for Package Body XXAH_ATTCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_ATTCH_PKG" AS

  l_one_minute NUMBER := 1/(24*60);

  PROCEDURE init_fad_rowid IS
  BEGIN
    fad_rowid_table := fad_rowid_table_old;
    fad_rowid_count := 0;
  END init_fad_rowid;

  PROCEDURE add_fad_rowid ( fad_rowid IN NUMBER ) IS
  BEGIN
    IF NOT fad_in_after_statement
    THEN
      fad_rowid_count                  := fad_rowid_count + 1;
      fad_rowid_table(fad_rowid_count) := fad_rowid;
    END IF;
  END add_fad_rowid;

  PROCEDURE clear_fad_rowid IS
    CURSOR c_att
    ( b_att_doc_id IN fnd_attached_documents.attached_document_id%TYPE
    ) IS
      SELECT poh.po_header_id
      FROM   fnd_attached_documents fad
      ,      po_headers_all         poh
      WHERE  fad.entity_name                          = 'PO_HEADERS'
      AND    fad.attached_document_id                 = b_att_doc_id
      AND    fad.pk1_value                            = poh.po_header_id
      AND    NVL(poh.document_creation_method,'!@#$') = 'AWARD_SOURCING'
      AND    fad.creation_date - poh.creation_date    < l_one_minute;
      l_poh_id    po_headers_all.po_header_id%TYPE;
      l_att_found BOOLEAN;
  BEGIN
    fad_in_after_statement := TRUE;

    IF NVL(fnd_profile.value('XXPON_NO_ATTACHMENT_COPY'),'N') = 'Y'
    THEN
      FOR i IN 1 .. fad_rowid_count
      LOOP
        OPEN  c_att ( fad_rowid_table(i) );
        FETCH c_att INTO l_poh_id;
        l_att_found := c_att%FOUND;
        CLOSE c_att;

        IF l_att_found
        THEN
          fnd_attached_documents2_pkg.delete_attachments
          (x_entity_name              => 'PO_HEADERS'
          ,x_pk1_value                => to_char(l_poh_id)
          ,x_pk2_value                => ''
          ,x_pk3_value                => ''
          ,x_pk4_value                => ''
          ,x_pk5_value                => ''
          ,x_delete_document_flag     => 'Y'
          ,x_automatically_added_flag => ''
          );
        END IF;
      END LOOP;
    END IF;

    fad_in_after_statement := FALSE;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_att%ISOPEN THEN CLOSE c_att; END IF;
  END clear_fad_rowid;

  PROCEDURE remove_terms ( p_po_header_id IN NUMBER ) IS
    l_return_status VARCHAR2(4000);
  BEGIN
    IF NVL(fnd_profile.value('XXPON_NO_TERMS_COPY'),'N') = 'Y'
    THEN
      fnd_msg_pub.initialize ;
      okc_terms_util_pvt.delete_doc
        ( x_return_status => l_return_status
        , p_doc_type      => 'PA_BLANKET'
        , p_doc_id        => p_po_header_id
        );
      UPDATE po_headers_all
      SET    conterms_exist_flag        = 'N'
      ,      conterms_articles_upd_date = to_date(null)
      ,      conterms_deliv_upd_date    = to_date(null)
      WHERE  po_header_id = p_po_header_id
      ;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END remove_terms;

END xxah_attch_pkg;

/
