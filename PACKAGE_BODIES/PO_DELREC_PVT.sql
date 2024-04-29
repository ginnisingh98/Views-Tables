--------------------------------------------------------
--  DDL for Package Body PO_DELREC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DELREC_PVT" AS
/* $Header: POXVDRDB.pls 120.6.12010000.2 2008/08/11 12:48:27 bisdas ship $ */
c_log_head    CONSTANT VARCHAR2(30) := 'po.plsql.PO_DELREC_PVT.';
x_progress             VARCHAR2(4)  := NULL;

g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_debug_stmt  CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

PROCEDURE get_approved_po
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_id          IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
);

PROCEDURE get_cancelled_po
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_id          IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
);

PROCEDURE get_opened_po
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_id          IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
);

PROCEDURE get_closed_po
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_id          IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
);

PROCEDURE get_finally_closed_po
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_id          IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
);

PROCEDURE get_approved_release
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
);

PROCEDURE get_cancelled_release
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
);


PROCEDURE get_opened_release
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
);

PROCEDURE get_closed_release
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
);

PROCEDURE get_finally_closed_release
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
);

PROCEDURE make_rcv_call
(
    p_api_version      IN               NUMBER,
    p_action_rec       IN OUT NOCOPY    WSH_BULK_TYPES_GRP.action_parameters_rectype,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_action           IN               VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_id          IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type           );

-- Bug 3581992 START
PROCEDURE debug_fte_rec
(
  p_fte_rec IN OE_WSH_BULK_GRP.Line_Rec_Type
);
-- Bug 3581992 END

-------------------------------------------------------------------------------
--Start of Comments
--Name: create_update_delrec
--Pre-reqs:
--  None.
--Modifies:
--  l_fte_rec
--Locks:
--  None.
--Function:
--  Call FTE's API to create delivery record for Standard Purchase Order
--  and Blanket Release
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_action
--  Specifies doc control action.
--p_doc_type
--  Differentiates between the doc being a PO or Release.
--p_doc_subtype
--  Specifies Standard PO or Blanket Release.
--p_doc_id
--  Corresponding to po_header_id or po_release_id.
--p_line_id
--  Corresponding to po_line_id
--p_line_location_id
--  Corresponding to po_line_location_id
--IN OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_msg_count
--  Error messages number.
--x_msg_data
--  Error messages body.
--Testing:
--  Need to integrate FTE to implement the testing.
--End of Comments
-------------------------------------------------------------------------------


PROCEDURE create_update_delrec
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    x_msg_count        IN OUT NOCOPY    NUMBER,
    x_msg_data         IN OUT NOCOPY    VARCHAR2,
    p_action           IN               VARCHAR2,
    p_doc_type         IN               VARCHAR2,
    p_doc_subtype      IN               VARCHAR2,
    p_doc_id           IN               NUMBER,
    p_line_id          IN               NUMBER,
    p_line_location_id IN               NUMBER
)
IS
l_api_name       CONSTANT VARCHAR2(100)   :=    'create_update_delrec';
l_api_version    CONSTANT NUMBER          :=    1.0;
l_shipping_control        PO_HEADERS_ALL.shipping_control%TYPE;

-- define record of tables for bulk processing
l_action_rec     WSH_BULK_TYPES_GRP.action_parameters_rectype;
l_fte_rec        OE_WSH_BULK_GRP.Line_Rec_Type;
l_fte_out_rec    WSH_BULK_TYPES_GRP.Bulk_process_out_rec_type;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT    create_update_delrec;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    x_progress:='000';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name ||'.begin', 'Check API Call Compatibility');
    END IF;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
           (
               p_current_version_number => l_api_version,
               p_caller_version_number  => p_api_version,
               p_api_name               => l_api_name,
               p_pkg_name               => 'PO_DELREC_PVT'
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --<R12 OTM INTEGRATION START>: Call OTM if installed. Otherwise, execute
    --old FTE integration
    IF (PO_OTM_INTEGRATION_PVT.is_otm_installed()) THEN

      x_progress := '005';

      PO_OTM_INTEGRATION_PVT.handle_doc_update(
        p_doc_type       => p_doc_type
      , p_doc_id         => p_doc_id
      , p_action         => p_action
      , p_line_id        => p_line_id
      , p_line_loc_id    => p_line_location_id);

      x_progress := '006';

    ELSIF (WSH_UTIL_CORE.fte_is_installed() = 'Y') THEN

      x_progress := '008';

      l_action_rec.Caller      := 'PO';
      l_action_rec.Phase       := '';

      x_progress:='010';
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name ||'.begin', 'Check action ' || p_action);
      END IF;
      IF (p_action IN ('APPROVE_DOCUMENT', 'APPROVE', 'APPROVE AND RESERVE')) THEN
          l_action_rec.action_code := 'APPROVE_PO';
      ELSIF (p_action = 'CANCEL') THEN
          l_action_rec.action_code := 'CANCEL_PO';
      ELSIF (p_action IN ('OPEN', 'RECEIVE OPEN')) THEN
          l_action_rec.action_code := 'REOPEN_PO';
      ELSIF (p_action = 'CLOSE') THEN
          l_action_rec.action_code := 'CLOSE_PO';
      ELSIF (p_action = 'FINALLY CLOSE') THEN
          l_action_rec.action_code := 'FINAL_CLOSE';
      ELSIF (p_action = 'RECEIVE CLOSE') THEN
          l_action_rec.action_code := 'CLOSE_PO_FOR_RECEIVING';
      -- Receiving Codes
      ELSIF (p_action = 'ASN') THEN
          l_action_rec.action_code := 'ASN';
      ELSIF (p_action = 'CANCEL_ASN') THEN
          l_action_rec.action_code := 'CANCEL_ASN';
      ELSIF (p_action = 'RECEIPT') THEN
          l_action_rec.action_code := 'RECEIPT';
      ELSIF (p_action = 'MATCH') THEN
          l_action_rec.action_code := 'MATCH';
      ELSIF (p_action = 'RECEIPT_CORRECTION') THEN
          l_action_rec.action_code := 'RECEIPT_CORRECTION';
      ELSIF (p_action = 'CORRECT') THEN
          l_action_rec.action_code := 'RECEIPT_CORRECTION';
      ELSIF (p_action = 'RTV') THEN
          l_action_rec.action_code := 'RTV';
      ELSIF (p_action = 'RTV_CORRECTION') THEN
          l_action_rec.action_code := 'RTV_CORRECTION';
      ELSIF (p_action = 'RECEIPT_ADD') THEN
          l_action_rec.action_code := 'RECEIPT_ADD';
      ELSIF (p_action = 'RECEIPT_HEADER_UPD') THEN
          l_action_rec.action_code := 'RECEIPT_HEADER_UPD';
      ELSE
         --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         -- <OTM INTEGRATION FPJ>: changed exception to log and early
         -- return. Previously, calls to create_update_delrec were
         -- filtered for the action, but OTM responds to a different
         -- set of actions, so the filters have been removed.
         IF(FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.level_statement, c_log_head || l_api_name,
                         'Unrecognized command for FTE: ' || p_action ||
                         ', returning.');
         END IF;
        RETURN;
      END IF;


      -- The following is for query data to create delivery record for:
      -- Standard PO, Standard PO referencing GA or Contract
      x_progress:='015';
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name ||'.begin', 'Check doc type is ' || p_doc_type || ' doc subtype is ' || p_doc_subtype || '
   doc id is ' || p_doc_id || ' line id is ' || p_line_id || ' line location id is ' || p_line_location_id  );
      END IF;

      /* Bug 7232644: Checking of the value of the shipping control before calling the
         procedure make_rcv_call.*/

      IF ( p_doc_type = 'PO' AND p_doc_subtype = 'STANDARD' ) THEN
          SELECT shipping_control
            INTO l_shipping_control
            FROM PO_HEADERS_ALL
           WHERE po_header_id = p_doc_id;
      ELSIF ( p_doc_type = 'RELEASE' AND p_doc_subtype = 'BLANKET') THEN
          SELECT shipping_control
            INTO l_shipping_control
            FROM PO_RELEASES_ALL
           WHERE po_release_id = p_doc_id;
      ELSE
          l_shipping_control := NULL;
      END IF;

      --Bug#5009715 We should only call FTE API when Shipping Control is SUPPLIER or BUYER
      IF (nvl(l_shipping_control,'NONE') = 'NONE') THEN
          IF g_fnd_debug = 'Y' THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string(
                  log_level => FND_LOG.LEVEL_STATEMENT,
                  module    => c_log_head || l_api_name || '.begin',
                  message   => 'FTE API is not called because shipping control is set to NULL or NONE'
              );
              END IF;
          END IF;
          RETURN;
      END IF;


      IF ( p_doc_type = 'RCV') THEN
          l_action_rec.Entity := 'PO';
          make_rcv_call(
              p_api_version       =>  l_api_version,
              p_action_rec        =>  l_action_rec,
              x_return_status     =>  x_return_status,
              p_action            =>  p_action,
              p_header_id         =>  p_doc_id,
              p_line_id           =>  p_line_id,
              p_line_location_id  =>  p_line_location_id,
              x_fte_rec           =>  l_fte_rec
          );

      END IF;



      IF ( p_doc_type = 'PO' AND p_doc_subtype = 'STANDARD' ) THEN
          l_action_rec.Entity      := 'PO';
          IF (l_action_rec.action_code = 'APPROVE_PO') THEN
              get_approved_po
              (
                  p_api_version         =>    l_api_version,
                  x_return_status       =>    x_return_status,
                  p_header_id           =>    p_doc_id,
                  p_line_id             =>    p_line_id,
                  p_line_location_id    =>    p_line_location_id,
                  x_fte_rec             =>    l_fte_rec
              );
          ELSIF (l_action_rec.action_code = 'CANCEL_PO') THEN
              get_cancelled_po
              (
                  p_api_version         =>    l_api_version,
                  x_return_status       =>    x_return_status,
                  p_header_id           =>    p_doc_id,
                  p_line_id             =>    p_line_id,
                  p_line_location_id    =>    p_line_location_id,
                  x_fte_rec             =>    l_fte_rec
              );
          ELSIF (l_action_rec.action_code = 'REOPEN_PO') THEN
              get_opened_po
              (
                  p_api_version         =>    l_api_version,
                  x_return_status       =>    x_return_status,
                  p_header_id           =>    p_doc_id,
                  p_line_id             =>    p_line_id,
                  p_line_location_id    =>    p_line_location_id,
                  x_fte_rec             =>    l_fte_rec
              );
          ELSIF (l_action_rec.action_code IN ('CLOSE_PO', 'CLOSE_PO_FOR_RECEIVING')) THEN
              get_closed_po
              (
                  p_api_version         =>    l_api_version,
                  x_return_status       =>    x_return_status,
                  p_header_id           =>    p_doc_id,
                  p_line_id             =>    p_line_id,
                  p_line_location_id    =>    p_line_location_id,
                  x_fte_rec             =>    l_fte_rec
              );
          ELSIF (l_action_rec.action_code = 'FINAL_CLOSE') THEN
              get_finally_closed_po
              (
                  p_api_version         =>    l_api_version,
                  x_return_status       =>    x_return_status,
                  p_header_id           =>    p_doc_id,
                  p_line_id             =>    p_line_id,
                  p_line_location_id    =>    p_line_location_id,
                  x_fte_rec             =>    l_fte_rec
              );
          ELSE
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;    -- IF (l_action_rec.action_code = 'APPROVE_PO')

          x_progress:='020';
          -- Bug 3581992 START
          IF (g_debug_stmt) THEN
            debug_fte_rec(l_fte_rec); -- Log the contents of l_fte_rec.
          END IF;
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            -- Bug 3581992 END

          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name ||'.begin', 'Call WSH_BULK_PROCESS_GRP.create_update_delivery_details');
          END IF;

          -- Bug 3602512 START
          -- Do not call the FTE API if we do not have any records in l_fte_rec.
          -- ex. This happens when we approve a PO that requires signature,
          -- because the shipments will still have approved_flag = N until
          -- the PO is signed.
          IF (l_fte_rec.po_shipment_line_id.count > 0) THEN

            WSH_BULK_PROCESS_GRP.create_update_delivery_details
               (
                p_api_version_number    =>    l_api_version,
                p_init_msg_list         =>    FND_API.G_FALSE,
                p_commit                =>    FND_API.G_FALSE,
                p_action_prms           =>    l_action_rec,
                p_line_rec              =>    l_fte_rec,
                x_Out_Rec               =>    l_fte_out_rec,
                x_return_status         =>    x_return_status,
                x_msg_count             =>    x_msg_count,
                x_msg_data              =>    x_msg_data
               );

          ELSE -- l_fte_rec.po_shipment_line_id.count = 0
            IF (g_debug_stmt) THEN
              PO_DEBUG.debug_stmt ( p_log_head => c_log_head||l_api_name,
                                    p_token => NULL,
                                    p_message =>
                'l_fte_rec has no records, so do not call the FTE API.' );
            END IF;
          END IF; -- l_fte_rec
          -- Bug 3602512 END

      -- The following is for query data to create delivery record for:
      -- Blanket Release

      ELSIF ( p_doc_type = 'RELEASE' AND p_doc_subtype = 'BLANKET') THEN
          l_action_rec.Entity      := 'RELEASE';

          IF (l_action_rec.action_code = 'APPROVE_PO') THEN
              get_approved_release
              (
                  p_api_version         =>    l_api_version,
                  x_return_status       =>    x_return_status,
                  p_header_id           =>    p_doc_id,
                  p_line_location_id    =>    p_line_location_id,
                  x_fte_rec             =>    l_fte_rec
              );
          ELSIF (l_action_rec.action_code = 'CANCEL_PO') THEN
              get_cancelled_release
              (
                  p_api_version         =>    l_api_version,
                  x_return_status       =>    x_return_status,
                  p_header_id           =>    p_doc_id,
                  p_line_location_id    =>    p_line_location_id,
                  x_fte_rec             =>    l_fte_rec
              );
          ELSIF (l_action_rec.action_code = 'REOPEN_PO') THEN
              get_opened_release
              (
                  p_api_version         =>    l_api_version,
                  x_return_status       =>    x_return_status,
                  p_header_id           =>    p_doc_id,
                  p_line_location_id    =>    p_line_location_id,
                  x_fte_rec             =>    l_fte_rec
              );
          ELSIF (l_action_rec.action_code IN ('CLOSE_PO', 'CLOSE_PO_FOR_RECEIVING')) THEN
              get_closed_release
              (
                  p_api_version         =>    l_api_version,
                  x_return_status       =>    x_return_status,
                  p_header_id           =>    p_doc_id,
                  p_line_location_id    =>    p_line_location_id,
                  x_fte_rec             =>    l_fte_rec
              );
          ELSIF (l_action_rec.action_code = 'FINAL_CLOSE') THEN
              get_finally_closed_release
              (
                  p_api_version         =>    l_api_version,
                  x_return_status       =>    x_return_status,
                  p_header_id           =>    p_doc_id,
                  p_line_location_id    =>    p_line_location_id,
                  x_fte_rec             =>    l_fte_rec
              );
          ELSE
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;    -- IF (l_action_rec.action_code = 'APPROVE_PO')

          X_progress:='020';
          -- Bug 3581992 START
          IF (g_debug_stmt) THEN
            debug_fte_rec(l_fte_rec); -- Log the contents of l_fte_rec.
          END IF;
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            -- Bug 3581992 END

          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name ||'.begin', 'Call WSH_BULK_PROCESS_GRP.create_update_delivery_details');
          END IF;

          -- Bug 3602512 START
          -- Do not call the FTE API if we do not have any records in l_fte_rec.
          IF (l_fte_rec.po_shipment_line_id.count > 0) THEN

            WSH_BULK_PROCESS_GRP.create_update_delivery_details
               (
                p_api_version_number    =>    l_api_version,
                p_init_msg_list         =>    FND_API.G_FALSE,
                p_commit                =>    FND_API.G_FALSE,
                p_action_prms           =>    l_action_rec,
                p_line_rec              =>    l_fte_rec,
                x_Out_Rec               =>    l_fte_out_rec,
                x_return_status         =>    x_return_status,
                x_msg_count             =>    x_msg_count,
                x_msg_data              =>    x_msg_data
               );

          ELSE -- l_fte_rec.po_shipment_line_id.count = 0
            IF (g_debug_stmt) THEN
              PO_DEBUG.debug_stmt ( p_log_head => c_log_head||l_api_name,
                                    p_token => NULL,
                                    p_message =>
                'l_fte_rec has no records, so do not call the FTE API.' );
            END IF;
          END IF; -- l_fte_rec
          -- Bug 3602512 END

      END IF;    -- IF ( p_doc_type = 'PO' AND p_doc_subtype = 'STANDARD' )

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FOR i IN 1..x_msg_count LOOP
              x_msg_data := SUBSTR(x_msg_data || FND_MSG_PUB.Get(p_msg_index=>i, p_encoded =>'F' ), 1, 2000);
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF; --IF (PO_OTM_INTEGRATION_PVT.is_otm_installed()) THEN
    --<R12 OTM INTEGRATION END>

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_update_delrec;
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_fnd_debug = 'Y' THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
              FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,c_log_head || l_api_name ||'.EXCEPTION', 'Exception :'||x_progress||x_msg_data);
            END IF;
        END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_update_delrec;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF g_fnd_debug = 'Y' THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
              FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,c_log_head || l_api_name ||'.EXCEPTION', 'Exception :'||x_progress||sqlcode);
            END IF;
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO create_update_delrec;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF g_fnd_debug = 'Y' THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
              FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,c_log_head || l_api_name ||'.EXCEPTION', 'Exception :'||x_progress||sqlcode);
            END IF;
        END IF;
END;

/*
PROCEDURE test_rcv_call
IS
    l_action_rec    WSH_BULK_TYPES_GRP.action_parameters_rectype;
    l_return_status VARCHAR2(255);
    l_fte_rec       OE_WSH_BULK_GRP.Line_Rec_Type;
BEGIN
    l_action_rec.action_code := 'RECEIPT';
    l_action_rec.Caller      := 'PO';
    l_action_rec.Phase       := '';
    l_action_rec.Entity      := 'PO';
    make_rcv_call(
        1.0,
        l_action_rec,
        l_return_status,
        'RECEIPT',
        29431,
        NULL,
        NULL,
        l_fte_rec);

END;
*/


PROCEDURE make_rcv_call
(
    p_api_version      IN               NUMBER,
    p_action_rec       IN OUT NOCOPY    WSH_BULK_TYPES_GRP.action_parameters_rectype,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_action           IN               VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_id          IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
)
IS
    l_api_name      VARCHAR2(25) := 'make_rcv_call';
    l_fte_out_rec   WSH_BULK_TYPES_GRP.Bulk_process_out_rec_type;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_transaction_type  VARCHAR2(25);
    l_transaction_id    NUMBER;

BEGIN
    IF (p_action IN ('RECEIPT_CORRECTION', 'RTV_CORRECTION'))
    THEN
        l_transaction_type := 'CORRECT';

        -- this works because RTV is called inline
        SELECT transaction_id
        INTO l_transaction_id
        FROM rcv_fte_transaction_lines
        WHERE header_id = p_header_id
        AND line_id = p_line_id
        AND action = p_action
        AND reported_flag IN ( 'N', 'U')
        AND rownum = 1;

    ELSIF
        (p_action = 'RECEIPT')
    THEN
        l_transaction_type := 'RECEIVE';
    ELSIF
        (p_action = 'RTV')
    THEN
        l_transaction_type := 'RETURN TO VENDOR';

        -- this works because RTV is called inline
        SELECT transaction_id
        INTO l_transaction_id
        FROM rcv_fte_transaction_lines
        WHERE header_id = p_header_id
        AND line_id = p_line_id
        AND action = p_action
        AND reported_flag IN ( 'N', 'U')
        AND rownum = 1;
    ELSIF
        (p_action IN ('ASN', 'CANCEL_ASN', 'RECEIPT_ADD', 'RECEIPT_HEADER_UPD'))
    THEN l_transaction_type := 'RECEIVE';
    ELSIF
        (p_action = 'MATCH')
    THEN
        l_transaction_type := 'MATCH';
    END IF;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string (FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name || '.begin', 'In make_rcv_call');
    END IF;
-- INSERT INTO ben_test VALUES ('GOT HERE', SYSDATE);
   IF (p_line_id IS NULL) THEN
--    IF (1 = 1) THEN
        SELECT
            'PO',
            poh.po_header_id,
            pol.po_line_id,
            rsl.po_release_id,
            poh.vendor_id,
            poh.vendor_site_id,
            pol.item_id,
            pol.item_description,
            pol.hazard_class_id,
            pll.country_of_origin_code,
            pll.ship_to_location_id,
            poh.user_hold_flag,
            pll.qty_rcv_tolerance,
            pll.receive_close_tolerance,
            pll.quantity_shipped,
            rt.subinventory,
            pol.item_revision,
            rt.locator_id,
            pll.need_by_date,
            pll.promised_date,
            orf.party_id,
            poh.freight_terms_lookup_code,
            poh.fob_lookup_code,
            pol.vendor_product_num,
            msi.unit_weight,
            msi.weight_uom_code,
            msi.unit_volume,
            msi.volume_uom_code,
            rsh.ship_to_org_id,
            poh.segment1,
            DECODE (poh.type_lookup_code,
                'STANDARD', 1,
                'BLANKET', 2,
                1),
            fl.meaning,  -- begin
            pll.quantity,
            puom.uom_code,
            pll.quantity_cancelled,
            rsh.waybill_airbill_num,
            nvl(rsl.packing_slip, rsh.packing_slip),
            poh.org_id,
            pol.line_num,
            rsh.gross_weight, -- end
            rsh.gross_weight_uom_code,
            rsh.net_weight,
            rsh.net_weight_uom_code,
            rsh.tar_weight,
            rsh.tar_weight_uom_code,
            pll.price_override,
            poh.currency_code,
            pol.qc_grade,
            pll.secondary_quantity,
           suom.uom_code, --Bug 5130410 FP: BUG 5137236.secondary_unit_of_measure,
            pll.secondary_quantity,
            rsl.secondary_quantity_shipped,
            pll.secondary_quantity_cancelled,
            suom.uom_code, --Bug 5130410 FP: BUG 5137236.secondary_unit_of_measure,

            rsl.asn_lpn_id,  -- used to NVL with rt, they don't care about rt
            DECODE(p_action, 'ASN', rsl.quantity_shipped,
                             'RECEIPT', distquery.squant,
                             'MATCH', distquery.squant,
                             NVL(rt.quantity,0)),
            NVL(rtuom.uom_code, muom.uom_code),
            rt.secondary_quantity,
            NVL(rtsuom.uom_code, suom.uom_code),
            rsl.po_line_location_id,
            pll.shipment_num,
            por.release_num,
            pll.days_early_receipt_allowed,
            pll.days_late_receipt_allowed,
            poh.shipping_control,
            pll.drop_ship_flag,
            rsh.shipment_header_id,
            rsh.shipment_num,
            rsh.receipt_num,
            rsh.shipped_date,
            DECODE(p_action, 'ASN', rsh.expected_receipt_date, NVL(rt.transaction_date, SYSDATE)),
            rsh.bill_of_lading,
            rsh.num_of_containers,
            rsl.container_num,
            rsl.truck_num,
            rsl.shipment_line_id,
            pll.qty_rcv_exception_code,
            DECODE(p_action, 'RECEIPT', distquery.maxtrans, 'MATCH', distquery.maxtrans, rt.transaction_id),
            rsl.shipment_line_id,
            rsh.shipment_header_id,
            pll.closed_flag,
            pll.cancel_flag,
            pll.closed_code,
            DECODE (PLT.outside_operation_flag, 'Y', 'GB_OSP', 'GB'),
            pll.receipt_days_exception_code,
            pll.enforce_ship_to_location_code,
            poh.revision_num,
            por.revision_num,
            pll.last_update_date,
            rsl.ship_to_location_id,
            rsl.item_id,
            rsl.item_description,
            rt.country_of_origin_code,
            rsl.item_revision,
            orf2.party_id,
            rsh.freight_terms,
            rsl.vendor_item_num,
            rt.qc_grade,
            rsh.asn_type
        BULK COLLECT INTO
            x_fte_rec.source_code,
            x_fte_rec.header_id,
            x_fte_rec.line_id,
            x_fte_rec.source_blanket_reference_id,
            x_fte_rec.vendor_id,
            x_fte_rec.ship_from_site_id,
            x_fte_rec.inventory_item_id,
            x_fte_rec.item_description,
            x_fte_rec.hazard_class_id,
            x_fte_rec.country_of_origin,
            x_fte_rec.ship_to_location_id,
            x_fte_rec.hold_code,
            x_fte_rec.ship_tolerance_above,
            x_fte_rec.ship_tolerance_below,
            x_fte_rec.shipped_quantity,
            x_fte_rec.subinventory,
            x_fte_rec.revision,
            x_fte_rec.locator_id,
            x_fte_rec.request_date,
            x_fte_rec.schedule_ship_date,
            x_fte_rec.carrier_id,
            x_fte_rec.freight_terms_code,
            x_fte_rec.fob_point_code,
            x_fte_rec.supplier_item_num,
            x_fte_rec.net_weight,
            x_fte_rec.weight_uom_code,
            x_fte_rec.volume,
            x_fte_rec.volume_uom_code,
            x_fte_rec.organization_id,
            x_fte_rec.source_header_number,
            x_fte_rec.source_header_type_id, -- fix
            x_fte_rec.source_header_type_name,  -- begin
            x_fte_rec.ordered_quantity,
            x_fte_rec.order_quantity_uom,
            x_fte_rec.cancelled_quantity,
            x_fte_rec.tracking_number,
            x_fte_rec.packing_slip_number,
            x_fte_rec.org_id,
            x_fte_rec.source_line_number,  -- end
            x_fte_rec.rcv_gross_weight,
            x_fte_rec.rcv_gross_weight_uom_code,
            x_fte_rec.rcv_net_weight,
            x_fte_rec.rcv_net_weight_uom_code,
            x_fte_rec.rcv_tare_weight,
            x_fte_rec.rcv_tare_weight_uom_code,
            x_fte_rec.unit_list_price,
            x_fte_rec.currency_code,
            x_fte_rec.preferred_grade,
            x_fte_rec.ordered_quantity2,
            x_fte_rec.ordered_quantity_uom2,
            x_fte_rec.requested_quantity2,
            x_fte_rec.shipped_quantity2,
            x_fte_rec.cancelled_quantity2,
            x_fte_rec.requested_quantity_uom2,
            x_fte_rec.lpn_id,
            x_fte_rec.received_quantity,
            x_fte_rec.received_quantity_uom,
            x_fte_rec.received_quantity2,
            x_fte_rec.received_quantity2_uom,
            x_fte_rec.po_shipment_line_id,
            x_fte_rec.po_shipment_line_number,
            x_fte_rec.source_blanket_reference_num,
            x_fte_rec.days_early_receipt_allowed,
            x_fte_rec.days_late_receipt_allowed,
            x_fte_rec.shipping_control,
            x_fte_rec.drop_ship_flag,
            x_fte_rec.shipment_header_id,
            x_fte_rec.shipment_num,
            x_fte_rec.receipt_num,
            x_fte_rec.shipped_date,
            x_fte_rec.expected_receipt_date,
            x_fte_rec.bill_of_lading,
            x_fte_rec.num_of_containers,
            x_fte_rec.container_num,
            x_fte_rec.truck_num,
            x_fte_rec.shipment_line_id,
            x_fte_rec.qty_rcv_exception_code,
            x_fte_rec.rcv_transaction_id,
            x_fte_rec.rcv_parent_shipment_line_id,
            x_fte_rec.rcv_parent_shipment_header_id,
            x_fte_rec.closed_flag,
            x_fte_rec.cancelled_flag,
            x_fte_rec.closed_code,
            x_fte_rec.source_line_type_code,
            x_fte_rec.receipt_days_exception_code,
            x_fte_rec.enforce_ship_to_location_code,
            x_fte_rec.po_revision,
            x_fte_rec.release_revision,
            x_fte_rec.shipping_details_updated_on,
            x_fte_rec.rcv_ship_to_location_id,
            x_fte_rec.rcv_inventory_item_id,
            x_fte_rec.rcv_item_description,
            x_fte_rec.rcv_country_of_origin,
            x_fte_rec.rcv_revision,
            x_fte_rec.rcv_carrier_id,
            x_fte_rec.rcv_freight_terms_code,
            x_fte_rec.rcv_supplier_item_num,
            x_fte_rec.rcv_preferred_grade,
            x_fte_rec.asn_type
        FROM
            po_headers_all          poh,
            po_lines_all            pol,
            po_line_locations_all   pll,
            rcv_transactions        rt,
            mtl_system_items        msi,
            fnd_lookup_values       fl,
            po_releases_all         por,
            mtl_units_of_measure    muom,
            mtl_units_of_measure    suom,
            mtl_units_of_measure    puom,
            mtl_units_of_measure    rtuom,
            mtl_units_of_measure    rtsuom,
            rcv_shipment_headers    rsh,
            rcv_shipment_lines      rsl,
            org_freight             orf,
            org_freight             orf2,
            po_line_types_b         plt,
            (
            SELECT  shipment_header_id,
                    shipment_line_id,
                    sum(quantity) squant,
                    max(transaction_id) maxtrans
            FROM    rcv_transactions
            WHERE   shipment_header_id = p_header_id
            AND     transaction_type IN ('RECEIVE', 'MATCH')
            AND     p_action IN ('RECEIPT', 'MATCH')
            GROUP BY    shipment_line_id,
                        shipment_header_id
            UNION ALL
            SELECT  shipment_header_id,
                    shipment_line_id,
                    0 squant,
                    0 maxtrans
            FROM    rcv_shipment_lines
            WHERE   shipment_header_id = p_header_id
            AND     p_action NOT IN ('RECEIPT', 'MATCH')
            ) distquery
        WHERE
            rsl.shipment_header_id = p_header_id
        AND rsl.shipment_header_id = rsh.shipment_header_id
        AND rsl.shipment_header_id = distquery.shipment_header_id
        AND rsl.shipment_line_id = distquery.shipment_line_id
        AND (distquery.maxtrans = rt.transaction_id OR
             distquery.maxtrans = 0)
        AND rsl.po_header_id = poh.po_header_id
        AND rsl.po_line_id  = pol.po_line_id (+)
        AND pol.line_type_id = plt.line_type_id
        AND plt.order_type_lookup_code = 'QUANTITY' --bugfix 5525510
        AND rsl.po_line_location_id = pll.line_location_id (+)
        AND rsl.shipment_line_id = rt.shipment_line_id (+)
        AND (rt.transaction_type = l_transaction_type
            OR rt.transaction_type IS NULL)
        AND (rt.transaction_id IN
             (
                SELECT transaction_id
                FROM rcv_fte_transaction_lines
                WHERE header_id = p_header_id
                AND action = p_action
                AND reported_flag IN ( 'N', 'U')
             )
             OR rt.transaction_id IN
             (
                SELECT max(transaction_id)
                FROM rcv_transactions
                WHERE shipment_header_id = p_header_id
                AND transaction_type = 'RECEIVE'
                AND p_action = 'RECEIPT_HEADER_UPD'
             )
             OR p_action NOT IN ('RTV', 'RECEIPT_ADD', 'RECEIPT', 'RECEIPT_HEADER_UPD', 'MATCH')
            )
        AND rsl.po_release_id = por.po_release_id (+)
        AND fl.lookup_code = poh.type_lookup_code
        AND fl.lookup_type = 'PO TYPE'
        AND fl.language = USERENV('LANG')
        AND rsl.item_id = msi.inventory_item_id (+)
        AND rsl.to_organization_id = msi.organization_id (+)
        AND rsl.unit_of_measure = muom.unit_of_measure (+)
        AND rsl.secondary_unit_of_measure = suom.unit_of_measure (+)
        AND rt.unit_of_measure = rtuom.unit_of_measure (+)
        AND rt.secondary_unit_of_measure = rtsuom.unit_of_measure (+)
        AND pol.unit_meas_lookup_code = puom.unit_of_measure (+)
        AND pll.ship_via_lookup_code = orf.freight_code (+)
        AND pll.ship_to_organization_id = orf.organization_id (+)
        AND (orf.language = USERENV('LANG') OR orf.language IS NULL)
        AND rsh.freight_carrier_code = orf2.freight_code (+)
        AND rsh.ship_to_org_id = orf2.organization_id (+)
        AND (orf2.language = USERENV('LANG') OR orf2.language IS NULL);
    ELSE
        -- SAME QUERY, but with a line id constraint in the where clause
        -- This is messy to read, but performs much better than dynamic sql,
        -- Or an NVL in the WHERE clause.
    SELECT
        'PO',
        poh.po_header_id,
        pol.po_line_id,
        rsl.po_release_id,
        poh.vendor_id,
        poh.vendor_site_id,
        pol.item_id,
        pol.item_description,
        pol.hazard_class_id,
        pll.country_of_origin_code,
        pll.ship_to_location_id,
        poh.user_hold_flag,
        pll.qty_rcv_tolerance,
        pll.receive_close_tolerance,
        pll.quantity_shipped,
        rt.subinventory,
        pol.item_revision,
        rt.locator_id,
        pll.need_by_date,
        pll.promised_date,
        orf.party_id,
        poh.freight_terms_lookup_code,
        poh.fob_lookup_code,
        pol.vendor_product_num,
        msi.unit_weight,
        msi.weight_uom_code,
        msi.unit_volume,
        msi.volume_uom_code,
        rsh.ship_to_org_id,
        poh.segment1,
        DECODE( poh.type_lookup_code,
            'STANDARD', 1,
            'BLANKET', 2,
            1),
        fl.meaning,
        pll.quantity,
        puom.uom_code,
        pll.quantity_cancelled,
        rsh.waybill_airbill_num,
        nvl(rsl.packing_slip, rsh.packing_slip),
        poh.org_id,
        pol.line_num,
        rsh.gross_weight,
        rsh.gross_weight_uom_code,
        rsh.net_weight,
        rsh.net_weight_uom_code,
        rsh.tar_weight,
        rsh.tar_weight_uom_code,
        pll.price_override,
        poh.currency_code,
        pol.qc_grade,
        pll.secondary_quantity,
        suom.uom_code, --Bug 5130410 FP: BUG 5137236.secondary_unit_of_measure,
        pll.secondary_quantity,
        rsl.secondary_quantity_shipped,
        pll.secondary_quantity_cancelled,
        suom.uom_code, --Bug 5130410 FP: BUG 5137236.secondary_unit_of_measure,
        rsl.asn_lpn_id,  -- fte doesn't care about rt.lpn_id
        DECODE(p_action, 'ASN', rsl.quantity_shipped, NVL(rt.quantity,0)),
        NVL(rtuom.uom_code, muom.uom_code),
        rt.secondary_quantity,
        NVL(rtsuom.uom_code, suom.uom_code),
        rsl.po_line_location_id,
        pll.shipment_num,
        por.release_num,
        pll.days_early_receipt_allowed,
        pll.days_late_receipt_allowed,
        poh.shipping_control,
        pll.drop_ship_flag,
        rsh.shipment_header_id,
        rsh.shipment_num,
        rsh.receipt_num,
        rsh.shipped_date,
        DECODE(p_action, 'ASN', rsh.expected_receipt_date, NVL(rt.transaction_date, SYSDATE)),
        rsh.bill_of_lading,
        rsh.num_of_containers,
        rsl.container_num,
        rsl.truck_num,
        rsl.shipment_line_id,
        pll.qty_rcv_exception_code,
        rt.transaction_id,
        rsl.shipment_line_id,
        rsh.shipment_header_id,
        pll.closed_flag,
        pll.cancel_flag,
        pll.closed_code,
        DECODE(PLT.outside_operation_flag, 'Y', 'GB_OSP', 'GB'),
        pll.receipt_days_exception_code,
        pll.enforce_ship_to_location_code,
        poh.revision_num,
        por.revision_num,
        pll.last_update_date,
        rsl.ship_to_location_id,
        rsl.item_id,
        rsl.item_description,
        rt.country_of_origin_code,
        rsl.item_revision,
        orf2.party_id,
        rsh.freight_terms,
        rsl.vendor_item_num,
        rt.qc_grade,
        rsh.asn_type
    BULK COLLECT INTO
        x_fte_rec.source_code,
        x_fte_rec.header_id,
        x_fte_rec.line_id,
        x_fte_rec.source_blanket_reference_id,
        x_fte_rec.vendor_id,
        x_fte_rec.ship_from_site_id,
        x_fte_rec.inventory_item_id,
        x_fte_rec.item_description,
        x_fte_rec.hazard_class_id,
        x_fte_rec.country_of_origin,
        x_fte_rec.ship_to_location_id,
        x_fte_rec.hold_code,
        x_fte_rec.ship_tolerance_above,
        x_fte_rec.ship_tolerance_below,
        x_fte_rec.shipped_quantity,
        x_fte_rec.subinventory,
        x_fte_rec.revision,
        x_fte_rec.locator_id,
        x_fte_rec.request_date,
        x_fte_rec.schedule_ship_date,
        x_fte_rec.carrier_id,
        x_fte_rec.freight_terms_code,
        x_fte_rec.fob_point_code,
        x_fte_rec.supplier_item_num,
        x_fte_rec.net_weight,
        x_fte_rec.weight_uom_code,
        x_fte_rec.volume,
        x_fte_rec.volume_uom_code,
        x_fte_rec.organization_id,
        x_fte_rec.source_header_number,
        x_fte_rec.source_header_type_id,
        x_fte_rec.source_header_type_name,
        x_fte_rec.ordered_quantity,
        x_fte_rec.order_quantity_uom,
        x_fte_rec.cancelled_quantity,
        x_fte_rec.tracking_number,
        x_fte_rec.packing_slip_number,
        x_fte_rec.org_id,
        x_fte_rec.source_line_number,
        x_fte_rec.rcv_gross_weight,
        x_fte_rec.rcv_gross_weight_uom_code,
        x_fte_rec.rcv_net_weight,
        x_fte_rec.rcv_net_weight_uom_code,
        x_fte_rec.rcv_tare_weight,
        x_fte_rec.rcv_tare_weight_uom_code,
        x_fte_rec.unit_list_price,
        x_fte_rec.currency_code,
        x_fte_rec.preferred_grade,
        x_fte_rec.ordered_quantity2,
        x_fte_rec.ordered_quantity_uom2,
        x_fte_rec.requested_quantity2,
        x_fte_rec.shipped_quantity2,
        x_fte_rec.cancelled_quantity2,
        x_fte_rec.requested_quantity_uom2,
        x_fte_rec.lpn_id,
        x_fte_rec.received_quantity,
        x_fte_rec.received_quantity_uom,
        x_fte_rec.received_quantity2,
        x_fte_rec.received_quantity2_uom,
        x_fte_rec.po_shipment_line_id,
        x_fte_rec.po_shipment_line_number,
        x_fte_rec.source_blanket_reference_num,
        x_fte_rec.days_early_receipt_allowed,
        x_fte_rec.days_late_receipt_allowed,
        x_fte_rec.shipping_control,
        x_fte_rec.drop_ship_flag,
        x_fte_rec.shipment_header_id,
        x_fte_rec.shipment_num,
        x_fte_rec.receipt_num,
        x_fte_rec.shipped_date,
        x_fte_rec.expected_receipt_date,
        x_fte_rec.bill_of_lading,
        x_fte_rec.num_of_containers,
        x_fte_rec.container_num,
        x_fte_rec.truck_num,
        x_fte_rec.shipment_line_id,
        x_fte_rec.qty_rcv_exception_code,
        x_fte_rec.rcv_transaction_id,
        x_fte_rec.rcv_parent_shipment_line_id,
        x_fte_rec.rcv_parent_shipment_header_id,
        x_fte_rec.closed_flag,
        x_fte_rec.cancelled_flag,
        x_fte_rec.closed_code,
        x_fte_rec.source_line_type_code,
        x_fte_rec.receipt_days_exception_code,
        x_fte_rec.enforce_ship_to_location_code,
        x_fte_rec.po_revision,
        x_fte_rec.release_revision,
        x_fte_rec.shipping_details_updated_on,
        x_fte_rec.rcv_ship_to_location_id,
        x_fte_rec.rcv_inventory_item_id,
        x_fte_rec.rcv_item_description,
        x_fte_rec.rcv_country_of_origin,
        x_fte_rec.rcv_revision,
        x_fte_rec.rcv_carrier_id,
        x_fte_rec.rcv_freight_terms_code,
        x_fte_rec.rcv_supplier_item_num,
        x_fte_rec.rcv_preferred_grade,
        x_fte_rec.asn_type
    FROM
        po_headers_all          poh,
        po_lines_all            pol,
        po_line_locations_all   pll,
        rcv_transactions        rt,
        mtl_system_items        msi,
        fnd_lookup_values       fl,
        po_releases_all         por,
        mtl_units_of_measure    muom,
        mtl_units_of_measure    suom,
        mtl_units_of_measure    puom,
        mtl_units_of_measure    rtuom,
        mtl_units_of_measure    rtsuom,
        rcv_shipment_headers    rsh,
        rcv_shipment_lines      rsl,
        org_freight             orf,
        org_freight             orf2,
        po_line_types_b         plt
    WHERE
        rsl.shipment_header_id = p_header_id
    AND rsl.shipment_line_id = p_line_id
    AND rsl.shipment_header_id = rsh.shipment_header_id
    AND rsl.po_header_id = poh.po_header_id
    AND rsl.po_line_id  = pol.po_line_id (+)
    AND pol.line_type_id = plt.line_type_id
    AND plt.order_type_lookup_code = 'QUANTITY' --bugfix 5525510
    AND rsl.po_line_location_id = pll.line_location_id (+)
    AND rsl.shipment_line_id = rt.shipment_line_id (+)
    AND (rt.transaction_type = l_transaction_type
         OR rt.transaction_type IS NULL)
    AND (rt.transaction_id = l_transaction_id
         OR l_transaction_id IS NULL)
    AND rsl.po_release_id = por.po_release_id (+)
    AND fl.lookup_code = poh.type_lookup_code
    AND fl.lookup_type = 'PO TYPE'
    AND fl.language = USERENV('LANG')
    AND rsl.item_id = msi.inventory_item_id (+)
    AND rsl.to_organization_id = msi.organization_id (+)
    AND rsl.unit_of_measure = muom.unit_of_measure (+)
    AND rt.unit_of_measure = rtuom.unit_of_measure (+)
    AND rt.secondary_unit_of_measure = rtsuom.unit_of_measure(+)
    AND rsl.secondary_unit_of_measure = suom.unit_of_measure (+)
    AND pol.unit_meas_lookup_code = puom.unit_of_measure (+)
    AND pll.ship_via_lookup_code = orf.freight_code (+)
    AND pll.ship_to_organization_id = orf.organization_id (+)
    AND (orf.language = USERENV('LANG') OR orf.language IS NULL)
    AND rsh.freight_carrier_code = orf2.freight_code (+)
    AND rsh.ship_to_org_id = orf2.organization_id (+)
    AND (orf2.language = USERENV('LANG') OR orf2.language IS NULL);

    END IF;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string (FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name || '.begin', 'After Queries, rows= ' || x_fte_rec.source_code.LAST);
    END IF;
-- INSERT INTO ben_test VALUES ('GOT HERE TOO', SYSDATE);
    p_action_rec.ship_from_location_id := rcv_table_functions.get_rsh_row_from_id(p_header_id).ship_from_location_id;

    WSH_BULK_PROCESS_GRP.create_update_delivery_details
        (
            p_api_version_number    =>    p_api_version,
            p_init_msg_list         =>    FND_API.G_FALSE,
            p_commit                =>    FND_API.G_FALSE,
            p_action_prms           =>    p_action_rec,
            p_line_rec              =>    x_fte_rec,
            x_Out_Rec               =>    l_fte_out_rec,
            x_return_status         =>    x_return_status,
            x_msg_count             =>    l_msg_count,
            x_msg_data              =>    l_msg_data
        );
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string (FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name || '.begin', 'RS: ' || x_return_status || ' x_msg_data: ' || l_msg_data);
      END IF;
 --INSERT INTO ben_test VALUES ('RS: ' || x_return_status || ' x_msg_data: ' || l_msg_data, SYSDATE);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        l_msg_data := 'Errm ' || sqlerrm;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string (FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name || '.begin', l_msg_data);
    END IF;
-- INSERT INTO ben_test VALUES (l_msg_data, SYSDATE);
        RAISE;

END make_rcv_call;


-------------------------------------------------------------------------------
--Start of Comments
--Name: get_approved_po
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Get data for delivery record from Approved Standard Purchase Order
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_header_id
--  Corresponding to po_header_id
--p_line_id
--  Corresponding to po_line_id
--p_line_location_id
--  Corresponding to po_line_location_id
--IN OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--Testing:
--  Need to integrate FTE to implement the testing.
--End of Comments
-------------------------------------------------------------------------------


PROCEDURE get_approved_po
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_id          IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
)
IS
l_api_name       CONSTANT VARCHAR2(100)    :=    'get_approved_po';
l_api_version    CONSTANT NUMBER           :=    1.0;

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
           (
               p_current_version_number => l_api_version,
               p_caller_version_number  => p_api_version,
               p_api_name               => l_api_name,
               p_pkg_name               => 'PO_DELREC_PVT'
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- The following is for query data for delivery record from:
    -- Approved Standard PO, Standard PO referencing GA or Contract

    --SQL What: Querying data from Approved Standard PO of quantity
    --SQL       based items.
    --SQL Where: MSI.inventory_item_id (+) = POL.item_id
    --SQL        NVL(MSI.organization_id, POLL.ship_to_organization_id)
    --SQL        = POLL.ship_to_organization_id
    --SQL        To get record for one-time item
    --SQL Why: Same as SQL What
    SELECT 'PO',    -- source code
           POH.po_header_id,
           POH.vendor_id,
           POH.vendor_site_id,
           POH.user_hold_flag,
           POH.freight_terms_lookup_code,
           POH.fob_lookup_code,
           POH.segment1,
           1,    -- stands for 'PO'
           PDT.type_name,
           POH.org_id,
           POH.currency_code,
           POH.shipping_control,
           POH.revision_num,
           POL.po_line_id,
           POL.item_id,
           POL.item_description,
           POL.hazard_class_id,
           POL.item_revision,
           POL.vendor_product_num,
           POL.line_num,
           DECODE(PLT.outside_operation_flag, 'Y', 'GB_OSP', 'GB'),
           POLL.line_location_id,
           POLL.country_of_origin_code,
           POLL.ship_to_location_id,
           POLL.qty_rcv_tolerance,
           POLL.receive_close_tolerance,
           POLL.quantity_shipped,
           POLL.need_by_date,
           POLL.promised_date,
           POLL.ship_to_organization_id,
           POLL.quantity,
           MUOM.uom_code,
           POLL.quantity_cancelled,
           POLL.price_override,
           POLL.preferred_grade,
           POLL.secondary_quantity,
           MUOM1.uom_code,
           POLL.secondary_quantity,
           POLL.secondary_quantity_cancelled,
           MUOM1.uom_code,
           POLL.shipment_num,
           POLL.days_early_receipt_allowed,
           POLL.days_late_receipt_allowed,
           POLL.drop_ship_flag,
           POLL.qty_rcv_exception_code,
           POLL.closed_flag,
           POLL.closed_code,
           POLL.cancel_flag,
           POLL.receipt_days_exception_code,
           POLL.enforce_ship_to_location_code,
           POLL.last_update_date,
           FRT.party_id,
           MSI.unit_weight,
           MSI.weight_uom_code,
           MSI.unit_volume,
           MSI.volume_uom_code
      BULK COLLECT INTO
           x_fte_rec.source_code,    -- Header
           x_fte_rec.header_id,
           x_fte_rec.vendor_id,
           x_fte_rec.ship_from_site_id,
           x_fte_rec.hold_code,
           x_fte_rec.freight_terms_code,
           x_fte_rec.fob_point_code,
           x_fte_rec.source_header_number,
           x_fte_rec.source_header_type_id,
           x_fte_rec.source_header_type_name,
           x_fte_rec.org_id,
           x_fte_rec.currency_code,
           x_fte_rec.shipping_control,
           x_fte_rec.po_revision,
           x_fte_rec.line_id,    -- Line
           x_fte_rec.inventory_item_id,
           x_fte_rec.item_description,
           x_fte_rec.hazard_class_id,
           x_fte_rec.revision,
           x_fte_rec.supplier_item_num,
           x_fte_rec.source_line_number,
           x_fte_rec.source_line_type_code,
           x_fte_rec.po_shipment_line_id,    -- Shipment
           x_fte_rec.country_of_origin,
           x_fte_rec.ship_to_location_id,
           x_fte_rec.ship_tolerance_above,
           x_fte_rec.ship_tolerance_below,
           x_fte_rec.shipped_quantity,
           x_fte_rec.request_date,
           x_fte_rec.schedule_ship_date,
           x_fte_rec.organization_id,
           x_fte_rec.ordered_quantity,
           x_fte_rec.order_quantity_uom,
           x_fte_rec.cancelled_quantity,
           x_fte_rec.unit_list_price,
           x_fte_rec.preferred_grade,
           x_fte_rec.ordered_quantity2,
           x_fte_rec.ordered_quantity_uom2,
           x_fte_rec.requested_quantity2,
           x_fte_rec.cancelled_quantity2,
           x_fte_rec.requested_quantity_uom2,
           x_fte_rec.po_shipment_line_number,
           x_fte_rec.days_early_receipt_allowed,
           x_fte_rec.days_late_receipt_allowed,
           x_fte_rec.drop_ship_flag,
           x_fte_rec.qty_rcv_exception_code,
           x_fte_rec.closed_flag,
           x_fte_rec.closed_code,
           x_fte_rec.cancelled_flag,
           x_fte_rec.receipt_days_exception_code,
           x_fte_rec.enforce_ship_to_location_code,
           x_fte_rec.shipping_details_updated_on,
           x_fte_rec.carrier_id,    -- Others
           x_fte_rec.net_weight,
           x_fte_rec.weight_uom_code,
           x_fte_rec.volume,
           x_fte_rec.volume_uom_code
      FROM PO_HEADERS           POH,
           PO_LINES             POL,
           PO_LINE_LOCATIONS    POLL,
           PO_LINE_TYPES_B      PLT,
           ORG_FREIGHT_TL       FRT,
           MTL_SYSTEM_ITEMS_B   MSI,
           PO_DOCUMENT_TYPES_VL PDT,
           MTL_UNITS_OF_MEASURE MUOM,
           MTL_UNITS_OF_MEASURE MUOM1
     WHERE POH.po_header_id = p_header_id
       AND PDT.document_type_code = 'PO'
       AND PDT.document_subtype = POH.type_lookup_code
       AND POL.po_header_id = POH.po_header_id
       AND POLL.po_line_id = POL.po_line_id
       AND POL.po_line_id = NVL(p_line_id, POL.po_line_id)
       AND POLL.line_location_id
           = NVL(p_line_location_id, POLL.line_location_id)
       AND POL.line_type_id = PLT.line_type_id
       AND PLT.order_type_lookup_code = 'QUANTITY'
       AND FRT.freight_code (+) = POH.ship_via_lookup_code
       AND FRT.language (+) = USERENV('LANG')
       AND NVL(FRT.organization_id, POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MSI.inventory_item_id (+) = POL.item_id
       AND NVL(MSI.organization_id,  POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MUOM.unit_of_measure(+) = POL.unit_meas_lookup_code
       AND MUOM1.unit_of_measure(+) = POLL.secondary_unit_of_measure
       AND NVL(POLL.approved_flag, 'N') = 'Y'
       AND NVL(POLL.cancel_flag, 'N') <> 'Y'; -- Bug 3581992

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
END;




-------------------------------------------------------------------------------
--Start of Comments
--Name: get_cancelled_po
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Get data for delivery record from Cancelled Standard Purchase Order
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_header_id
--  Corresponding to po_header_id
--p_line_id
--  Corresponding to po_line_id
--p_line_location_id
--  Corresponding to po_line_location_id
--IN OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--Testing:
--  Need to integrate FTE to implement the testing.
--End of Comments
-------------------------------------------------------------------------------


PROCEDURE get_cancelled_po
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_id          IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
)
IS
l_api_name       CONSTANT VARCHAR2(100)    :=    'get_cancelled_po';
l_api_version    CONSTANT NUMBER           :=    1.0;

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
           (
               p_current_version_number => l_api_version,
               p_caller_version_number  => p_api_version,
               p_api_name               => l_api_name,
               p_pkg_name               => 'PO_DELREC_PVT'
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- The following is for query data for delivery record from:
    -- Cancelled Standard PO, Standard PO referencing GA or Contract

    --SQL What: Querying data from Cancelled Standard PO of quantity
    --SQL       based items.
    --SQL Where: MSI.inventory_item_id (+) = POL.item_id
    --SQL        NVL(MSI.organization_id, POLL.ship_to_organization_id)
    --SQL        = POLL.ship_to_organization_id
    --SQL        To get record for one-time item
    --SQL Why: Same as SQL What
    SELECT 'PO',    -- source code
           POH.po_header_id,
           POH.vendor_id,
           POH.vendor_site_id,
           POH.user_hold_flag,
           POH.freight_terms_lookup_code,
           POH.fob_lookup_code,
           POH.segment1,
           1,    -- stands for 'PO'
           PDT.type_name,
           POH.org_id,
           POH.currency_code,
           POH.shipping_control,
           POH.revision_num,
           POL.po_line_id,
           POL.item_id,
           POL.item_description,
           POL.hazard_class_id,
           POL.item_revision,
           POL.vendor_product_num,
           POL.line_num,
           DECODE(PLT.outside_operation_flag, 'Y', 'GB_OSP', 'GB'),
           POLL.line_location_id,
           POLL.country_of_origin_code,
           POLL.ship_to_location_id,
           POLL.qty_rcv_tolerance,
           POLL.receive_close_tolerance,
           POLL.quantity_shipped,
           POLL.need_by_date,
           POLL.promised_date,
           POLL.ship_to_organization_id,
           POLL.quantity,
           MUOM.uom_code,
           POLL.quantity_cancelled,
           POLL.price_override,
           POLL.preferred_grade,
           POLL.secondary_quantity,
           MUOM1.uom_code,
           POLL.secondary_quantity,
           POLL.secondary_quantity_cancelled,
           MUOM1.uom_code,
           POLL.shipment_num,
           POLL.days_early_receipt_allowed,
           POLL.days_late_receipt_allowed,
           POLL.drop_ship_flag,
           POLL.qty_rcv_exception_code,
           POLL.closed_flag,
           POLL.closed_code,
           POLL.cancel_flag,
           POLL.receipt_days_exception_code,
           POLL.enforce_ship_to_location_code,
           POLL.last_update_date,
           FRT.party_id,
           MSI.unit_weight,
           MSI.weight_uom_code,
           MSI.unit_volume,
           MSI.volume_uom_code
      BULK COLLECT INTO
           x_fte_rec.source_code,    -- Header
           x_fte_rec.header_id,
           x_fte_rec.vendor_id,
           x_fte_rec.ship_from_site_id,
           x_fte_rec.hold_code,
           x_fte_rec.freight_terms_code,
           x_fte_rec.fob_point_code,
           x_fte_rec.source_header_number,
           x_fte_rec.source_header_type_id,
           x_fte_rec.source_header_type_name,
           x_fte_rec.org_id,
           x_fte_rec.currency_code,
           x_fte_rec.shipping_control,
           x_fte_rec.po_revision,
           x_fte_rec.line_id,    -- Line
           x_fte_rec.inventory_item_id,
           x_fte_rec.item_description,
           x_fte_rec.hazard_class_id,
           x_fte_rec.revision,
           x_fte_rec.supplier_item_num,
           x_fte_rec.source_line_number,
           x_fte_rec.source_line_type_code,
           x_fte_rec.po_shipment_line_id,    -- Shipment
           x_fte_rec.country_of_origin,
           x_fte_rec.ship_to_location_id,
           x_fte_rec.ship_tolerance_above,
           x_fte_rec.ship_tolerance_below,
           x_fte_rec.shipped_quantity,
           x_fte_rec.request_date,
           x_fte_rec.schedule_ship_date,
           x_fte_rec.organization_id,
           x_fte_rec.ordered_quantity,
           x_fte_rec.order_quantity_uom,
           x_fte_rec.cancelled_quantity,
           x_fte_rec.unit_list_price,
           x_fte_rec.preferred_grade,
           x_fte_rec.ordered_quantity2,
           x_fte_rec.ordered_quantity_uom2,
           x_fte_rec.requested_quantity2,
           x_fte_rec.cancelled_quantity2,
           x_fte_rec.requested_quantity_uom2,
           x_fte_rec.po_shipment_line_number,
           x_fte_rec.days_early_receipt_allowed,
           x_fte_rec.days_late_receipt_allowed,
           x_fte_rec.drop_ship_flag,
           x_fte_rec.qty_rcv_exception_code,
           x_fte_rec.closed_flag,
           x_fte_rec.closed_code,
           x_fte_rec.cancelled_flag,
           x_fte_rec.receipt_days_exception_code,
           x_fte_rec.enforce_ship_to_location_code,
           x_fte_rec.shipping_details_updated_on,
           x_fte_rec.carrier_id,    -- Others
           x_fte_rec.net_weight,
           x_fte_rec.weight_uom_code,
           x_fte_rec.volume,
           x_fte_rec.volume_uom_code
      FROM PO_HEADERS           POH,
           PO_LINES             POL,
           PO_LINE_LOCATIONS    POLL,
           PO_LINE_TYPES_B      PLT,
           ORG_FREIGHT_TL       FRT,
           MTL_SYSTEM_ITEMS_B   MSI,
           PO_DOCUMENT_TYPES_VL PDT,
           MTL_UNITS_OF_MEASURE MUOM,
           MTL_UNITS_OF_MEASURE MUOM1
     WHERE POH.po_header_id = p_header_id
       AND PDT.document_type_code = 'PO'
       AND PDT.document_subtype = POH.type_lookup_code
       AND POL.po_header_id = POH.po_header_id
       AND POLL.po_line_id = POL.po_line_id
       AND POL.po_line_id = NVL(p_line_id, POL.po_line_id)
       AND POLL.line_location_id
           = NVL(p_line_location_id, POLL.line_location_id)
       AND POL.line_type_id = PLT.line_type_id
       AND PLT.order_type_lookup_code = 'QUANTITY'
       AND FRT.freight_code (+) = POH.ship_via_lookup_code
       AND FRT.language (+) = USERENV('LANG')
       AND NVL(FRT.organization_id, POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MSI.inventory_item_id (+) = POL.item_id
       AND NVL(MSI.organization_id,  POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MUOM.unit_of_measure(+) = POL.unit_meas_lookup_code
       AND MUOM1.unit_of_measure(+) = POLL.secondary_unit_of_measure
       AND NVL(POLL.cancel_flag, 'N') = 'Y';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
END;




-------------------------------------------------------------------------------
--Start of Comments
--Name: get_opened_po
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Get data for delivery record from Opened Standard Purchase Order
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_header_id
--  Corresponding to po_header_id
--p_line_id
--  Corresponding to po_line_id
--p_line_location_id
--  Corresponding to po_line_location_id
--IN OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--Testing:
--  Need to integrate FTE to implement the testing.
--End of Comments
-------------------------------------------------------------------------------


PROCEDURE get_opened_po
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_id          IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
)
IS
l_api_name       CONSTANT VARCHAR2(100)    :=    'get_opened_po';
l_api_version    CONSTANT NUMBER           :=    1.0;

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
           (
               p_current_version_number => l_api_version,
               p_caller_version_number  => p_api_version,
               p_api_name               => l_api_name,
               p_pkg_name               => 'PO_DELREC_PVT'
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- The following is for query data for delivery record from:
    -- Opened Standard PO, Standard PO referencing GA or Contract

    --SQL What: Querying data from Opened Standard PO of quantity
    --SQL       based items.
    --SQL Where: MSI.inventory_item_id (+) = POL.item_id
    --SQL        NVL(MSI.organization_id, POLL.ship_to_organization_id)
    --SQL        = POLL.ship_to_organization_id
    --SQL        To get record for one-time item
    --SQL Why: Same as SQL What
    SELECT 'PO',    -- source code
           POH.po_header_id,
           POH.vendor_id,
           POH.vendor_site_id,
           POH.user_hold_flag,
           POH.freight_terms_lookup_code,
           POH.fob_lookup_code,
           POH.segment1,
           1,    -- stands for 'PO'
           PDT.type_name,
           POH.org_id,
           POH.currency_code,
           POH.shipping_control,
           POH.revision_num,
           POL.po_line_id,
           POL.item_id,
           POL.item_description,
           POL.hazard_class_id,
           POL.item_revision,
           POL.vendor_product_num,
           POL.line_num,
           DECODE(PLT.outside_operation_flag, 'Y', 'GB_OSP', 'GB'),
           POLL.line_location_id,
           POLL.country_of_origin_code,
           POLL.ship_to_location_id,
           POLL.qty_rcv_tolerance,
           POLL.receive_close_tolerance,
           POLL.quantity_shipped,
           POLL.need_by_date,
           POLL.promised_date,
           POLL.ship_to_organization_id,
           POLL.quantity,
           MUOM.uom_code,
           POLL.quantity_cancelled,
           POLL.price_override,
           POLL.preferred_grade,
           POLL.secondary_quantity,
           MUOM1.uom_code,
           POLL.secondary_quantity,
           POLL.secondary_quantity_cancelled,
           MUOM1.uom_code,
           POLL.shipment_num,
           POLL.days_early_receipt_allowed,
           POLL.days_late_receipt_allowed,
           POLL.drop_ship_flag,
           POLL.qty_rcv_exception_code,
           POLL.closed_flag,
           POLL.closed_code,
           POLL.cancel_flag,
           POLL.receipt_days_exception_code,
           POLL.enforce_ship_to_location_code,
           POLL.last_update_date,
           FRT.party_id,
           MSI.unit_weight,
           MSI.weight_uom_code,
           MSI.unit_volume,
           MSI.volume_uom_code
      BULK COLLECT INTO
           x_fte_rec.source_code,    -- Header
           x_fte_rec.header_id,
           x_fte_rec.vendor_id,
           x_fte_rec.ship_from_site_id,
           x_fte_rec.hold_code,
           x_fte_rec.freight_terms_code,
           x_fte_rec.fob_point_code,
           x_fte_rec.source_header_number,
           x_fte_rec.source_header_type_id,
           x_fte_rec.source_header_type_name,
           x_fte_rec.org_id,
           x_fte_rec.currency_code,
           x_fte_rec.shipping_control,
           x_fte_rec.po_revision,
           x_fte_rec.line_id,    -- Line
           x_fte_rec.inventory_item_id,
           x_fte_rec.item_description,
           x_fte_rec.hazard_class_id,
           x_fte_rec.revision,
           x_fte_rec.supplier_item_num,
           x_fte_rec.source_line_number,
           x_fte_rec.source_line_type_code,
           x_fte_rec.po_shipment_line_id,    -- Shipment
           x_fte_rec.country_of_origin,
           x_fte_rec.ship_to_location_id,
           x_fte_rec.ship_tolerance_above,
           x_fte_rec.ship_tolerance_below,
           x_fte_rec.shipped_quantity,
           x_fte_rec.request_date,
           x_fte_rec.schedule_ship_date,
           x_fte_rec.organization_id,
           x_fte_rec.ordered_quantity,
           x_fte_rec.order_quantity_uom,
           x_fte_rec.cancelled_quantity,
           x_fte_rec.unit_list_price,
           x_fte_rec.preferred_grade,
           x_fte_rec.ordered_quantity2,
           x_fte_rec.ordered_quantity_uom2,
           x_fte_rec.requested_quantity2,
           x_fte_rec.cancelled_quantity2,
           x_fte_rec.requested_quantity_uom2,
           x_fte_rec.po_shipment_line_number,
           x_fte_rec.days_early_receipt_allowed,
           x_fte_rec.days_late_receipt_allowed,
           x_fte_rec.drop_ship_flag,
           x_fte_rec.qty_rcv_exception_code,
           x_fte_rec.closed_flag,
           x_fte_rec.closed_code,
           x_fte_rec.cancelled_flag,
           x_fte_rec.receipt_days_exception_code,
           x_fte_rec.enforce_ship_to_location_code,
           x_fte_rec.shipping_details_updated_on,
           x_fte_rec.carrier_id,    -- Others
           x_fte_rec.net_weight,
           x_fte_rec.weight_uom_code,
           x_fte_rec.volume,
           x_fte_rec.volume_uom_code
      FROM PO_HEADERS           POH,
           PO_LINES             POL,
           PO_LINE_LOCATIONS    POLL,
           PO_LINE_TYPES_B      PLT,
           ORG_FREIGHT_TL       FRT,
           MTL_SYSTEM_ITEMS_B   MSI,
           PO_DOCUMENT_TYPES_VL PDT,
           MTL_UNITS_OF_MEASURE MUOM,
           MTL_UNITS_OF_MEASURE MUOM1
     WHERE POH.po_header_id = p_header_id
       AND PDT.document_type_code = 'PO'
       AND PDT.document_subtype = POH.type_lookup_code
       AND POL.po_header_id = POH.po_header_id
       AND POLL.po_line_id = POL.po_line_id
       AND POL.po_line_id = NVL(p_line_id, POL.po_line_id)
       AND POLL.line_location_id
           = NVL(p_line_location_id, POLL.line_location_id)
       AND POL.line_type_id = PLT.line_type_id
       AND PLT.order_type_lookup_code = 'QUANTITY'
       AND FRT.freight_code (+) = POH.ship_via_lookup_code
       AND FRT.language (+) = USERENV('LANG')
       AND NVL(FRT.organization_id, POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MSI.inventory_item_id (+) = POL.item_id
       AND NVL(MSI.organization_id,  POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MUOM.unit_of_measure(+) = POL.unit_meas_lookup_code
       AND MUOM1.unit_of_measure(+) = POLL.secondary_unit_of_measure
       AND NVL(POLL.closed_code, 'OPEN') = 'OPEN'
       AND NVL(POLL.cancel_flag, 'N') <> 'Y'; -- Bug 3581992

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
END;




-------------------------------------------------------------------------------
--Start of Comments
--Name: get_closed_po
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Get data for delivery record from Closed Standard Purchase Order
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_header_id
--  Corresponding to po_header_id
--p_line_id
--  Corresponding to po_line_id
--p_line_location_id
--  Corresponding to po_line_location_id
--IN OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--Testing:
--  Need to integrate FTE to implement the testing.
--End of Comments
-------------------------------------------------------------------------------


PROCEDURE get_closed_po
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_id          IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
)
IS
l_api_name       CONSTANT VARCHAR2(100)    :=    'get_closed_po';
l_api_version    CONSTANT NUMBER           :=    1.0;

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
           (
               p_current_version_number => l_api_version,
               p_caller_version_number  => p_api_version,
               p_api_name               => l_api_name,
               p_pkg_name               => 'PO_DELREC_PVT'
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- The following is for query data for delivery record from:
    -- Closed Standard PO, Standard PO referencing GA or Contract

    --SQL What: Querying data from Closed Standard PO of quantity
    --SQL       based items.
    --SQL Where: MSI.inventory_item_id (+) = POL.item_id
    --SQL        NVL(MSI.organization_id, POLL.ship_to_organization_id)
    --SQL        = POLL.ship_to_organization_id
    --SQL        To get record for one-time item
    --SQL Why: Same as SQL What
    SELECT 'PO',    -- source code
           POH.po_header_id,
           POH.vendor_id,
           POH.vendor_site_id,
           POH.user_hold_flag,
           POH.freight_terms_lookup_code,
           POH.fob_lookup_code,
           POH.segment1,
           1,    -- stands for 'PO'
           PDT.type_name,
           POH.org_id,
           POH.currency_code,
           POH.shipping_control,
           POH.revision_num,
           POL.po_line_id,
           POL.item_id,
           POL.item_description,
           POL.hazard_class_id,
           POL.item_revision,
           POL.vendor_product_num,
           POL.line_num,
           DECODE(PLT.outside_operation_flag, 'Y', 'GB_OSP', 'GB'),
           POLL.line_location_id,
           POLL.country_of_origin_code,
           POLL.ship_to_location_id,
           POLL.qty_rcv_tolerance,
           POLL.receive_close_tolerance,
           POLL.quantity_shipped,
           POLL.need_by_date,
           POLL.promised_date,
           POLL.ship_to_organization_id,
           POLL.quantity,
           MUOM.uom_code,
           POLL.quantity_cancelled,
           POLL.price_override,
           POLL.preferred_grade,
           POLL.secondary_quantity,
           MUOM1.uom_code,
           POLL.secondary_quantity,
           POLL.secondary_quantity_cancelled,
           MUOM1.uom_code,
           POLL.shipment_num,
           POLL.days_early_receipt_allowed,
           POLL.days_late_receipt_allowed,
           POLL.drop_ship_flag,
           POLL.qty_rcv_exception_code,
           POLL.closed_flag,
           POLL.closed_code,
           POLL.cancel_flag,
           POLL.receipt_days_exception_code,
           POLL.enforce_ship_to_location_code,
           POLL.last_update_date,
           FRT.party_id,
           MSI.unit_weight,
           MSI.weight_uom_code,
           MSI.unit_volume,
           MSI.volume_uom_code
      BULK COLLECT INTO
           x_fte_rec.source_code,    -- Header
           x_fte_rec.header_id,
           x_fte_rec.vendor_id,
           x_fte_rec.ship_from_site_id,
           x_fte_rec.hold_code,
           x_fte_rec.freight_terms_code,
           x_fte_rec.fob_point_code,
           x_fte_rec.source_header_number,
           x_fte_rec.source_header_type_id,
           x_fte_rec.source_header_type_name,
           x_fte_rec.org_id,
           x_fte_rec.currency_code,
           x_fte_rec.shipping_control,
           x_fte_rec.po_revision,
           x_fte_rec.line_id,    -- Line
           x_fte_rec.inventory_item_id,
           x_fte_rec.item_description,
           x_fte_rec.hazard_class_id,
           x_fte_rec.revision,
           x_fte_rec.supplier_item_num,
           x_fte_rec.source_line_number,
           x_fte_rec.source_line_type_code,
           x_fte_rec.po_shipment_line_id,    -- Shipment
           x_fte_rec.country_of_origin,
           x_fte_rec.ship_to_location_id,
           x_fte_rec.ship_tolerance_above,
           x_fte_rec.ship_tolerance_below,
           x_fte_rec.shipped_quantity,
           x_fte_rec.request_date,
           x_fte_rec.schedule_ship_date,
           x_fte_rec.organization_id,
           x_fte_rec.ordered_quantity,
           x_fte_rec.order_quantity_uom,
           x_fte_rec.cancelled_quantity,
           x_fte_rec.unit_list_price,
           x_fte_rec.preferred_grade,
           x_fte_rec.ordered_quantity2,
           x_fte_rec.ordered_quantity_uom2,
           x_fte_rec.requested_quantity2,
           x_fte_rec.cancelled_quantity2,
           x_fte_rec.requested_quantity_uom2,
           x_fte_rec.po_shipment_line_number,
           x_fte_rec.days_early_receipt_allowed,
           x_fte_rec.days_late_receipt_allowed,
           x_fte_rec.drop_ship_flag,
           x_fte_rec.qty_rcv_exception_code,
           x_fte_rec.closed_flag,
           x_fte_rec.closed_code,
           x_fte_rec.cancelled_flag,
           x_fte_rec.receipt_days_exception_code,
           x_fte_rec.enforce_ship_to_location_code,
           x_fte_rec.shipping_details_updated_on,
           x_fte_rec.carrier_id,    -- Others
           x_fte_rec.net_weight,
           x_fte_rec.weight_uom_code,
           x_fte_rec.volume,
           x_fte_rec.volume_uom_code
      FROM PO_HEADERS           POH,
           PO_LINES             POL,
           PO_LINE_LOCATIONS    POLL,
           PO_LINE_TYPES_B      PLT,
           ORG_FREIGHT_TL       FRT,
           MTL_SYSTEM_ITEMS_B   MSI,
           PO_DOCUMENT_TYPES_VL PDT,
           MTL_UNITS_OF_MEASURE MUOM,
           MTL_UNITS_OF_MEASURE MUOM1
     WHERE POH.po_header_id = p_header_id
       AND PDT.document_type_code = 'PO'
       AND PDT.document_subtype = POH.type_lookup_code
       AND POL.po_header_id = POH.po_header_id
       AND POLL.po_line_id = POL.po_line_id
       AND POL.po_line_id = NVL(p_line_id, POL.po_line_id)
       AND POLL.line_location_id
           = NVL(p_line_location_id, POLL.line_location_id)
       AND POL.line_type_id = PLT.line_type_id
       AND PLT.order_type_lookup_code = 'QUANTITY'
       AND FRT.freight_code (+) = POH.ship_via_lookup_code
       AND FRT.language (+) = USERENV('LANG')
       AND NVL(FRT.organization_id, POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MSI.inventory_item_id (+) = POL.item_id
       AND NVL(MSI.organization_id,  POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MUOM.unit_of_measure(+) = POL.unit_meas_lookup_code
       AND MUOM1.unit_of_measure(+) = POLL.secondary_unit_of_measure
       AND NVL(POLL.closed_code, 'OPEN') IN ('CLOSED', 'CLOSED FOR RECEIVING')
       AND NVL(POLL.cancel_flag, 'N') <> 'Y'; -- Bug 3581992

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
END;




-------------------------------------------------------------------------------
--Start of Comments
--Name: get_finally_closed_po
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Get data for delivery record from Finally Closed Standard Purchase Order
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_header_id
--  Corresponding to po_header_id
--p_line_id
--  Corresponding to po_line_id
--p_line_location_id
--  Corresponding to po_line_location_id
--IN OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--Testing:
--  Need to integrate FTE to implement the testing.
--End of Comments
-------------------------------------------------------------------------------


PROCEDURE get_finally_closed_po
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_id          IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
)
IS
l_api_name       CONSTANT VARCHAR2(100)    :=    'get_finally_closed_po';
l_api_version    CONSTANT NUMBER           :=    1.0;

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
           (
               p_current_version_number => l_api_version,
               p_caller_version_number  => p_api_version,
               p_api_name               => l_api_name,
               p_pkg_name               => 'PO_DELREC_PVT'
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- The following is for query data for delivery record from:
    -- Finally Closed Standard PO, Standard PO referencing GA or Contract

    --SQL What: Querying data from Finally Closed Standard PO of
    --SQL       quantity based items.
    --SQL Where: MSI.inventory_item_id (+) = POL.item_id
    --SQL        NVL(MSI.organization_id, POLL.ship_to_organization_id)
    --SQL        = POLL.ship_to_organization_id
    --SQL        To get record for one-time item
    --SQL Why: Same as SQL What
    SELECT 'PO',    -- source code
           POH.po_header_id,
           POH.vendor_id,
           POH.vendor_site_id,
           POH.user_hold_flag,
           POH.freight_terms_lookup_code,
           POH.fob_lookup_code,
           POH.segment1,
           1,    -- stands for 'PO'
           PDT.type_name,
           POH.org_id,
           POH.currency_code,
           POH.shipping_control,
           POH.revision_num,
           POL.po_line_id,
           POL.item_id,
           POL.item_description,
           POL.hazard_class_id,
           POL.item_revision,
           POL.vendor_product_num,
           POL.line_num,
           DECODE(PLT.outside_operation_flag, 'Y', 'GB_OSP', 'GB'),
           POLL.line_location_id,
           POLL.country_of_origin_code,
           POLL.ship_to_location_id,
           POLL.qty_rcv_tolerance,
           POLL.receive_close_tolerance,
           POLL.quantity_shipped,
           POLL.need_by_date,
           POLL.promised_date,
           POLL.ship_to_organization_id,
           POLL.quantity,
           MUOM.uom_code,
           POLL.quantity_cancelled,
           POLL.price_override,
           POLL.preferred_grade,
           POLL.secondary_quantity,
           MUOM1.uom_code,
           POLL.secondary_quantity,
           POLL.secondary_quantity_cancelled,
           MUOM1.uom_code,
           POLL.shipment_num,
           POLL.days_early_receipt_allowed,
           POLL.days_late_receipt_allowed,
           POLL.drop_ship_flag,
           POLL.qty_rcv_exception_code,
           POLL.closed_flag,
           POLL.closed_code,
           POLL.cancel_flag,
           POLL.receipt_days_exception_code,
           POLL.enforce_ship_to_location_code,
           POLL.last_update_date,
           FRT.party_id,
           MSI.unit_weight,
           MSI.weight_uom_code,
           MSI.unit_volume,
           MSI.volume_uom_code
      BULK COLLECT INTO
           x_fte_rec.source_code,    -- Header
           x_fte_rec.header_id,
           x_fte_rec.vendor_id,
           x_fte_rec.ship_from_site_id,
           x_fte_rec.hold_code,
           x_fte_rec.freight_terms_code,
           x_fte_rec.fob_point_code,
           x_fte_rec.source_header_number,
           x_fte_rec.source_header_type_id,
           x_fte_rec.source_header_type_name,
           x_fte_rec.org_id,
           x_fte_rec.currency_code,
           x_fte_rec.shipping_control,
           x_fte_rec.po_revision,
           x_fte_rec.line_id,    -- Line
           x_fte_rec.inventory_item_id,
           x_fte_rec.item_description,
           x_fte_rec.hazard_class_id,
           x_fte_rec.revision,
           x_fte_rec.supplier_item_num,
           x_fte_rec.source_line_number,
           x_fte_rec.source_line_type_code,
           x_fte_rec.po_shipment_line_id,    -- Shipment
           x_fte_rec.country_of_origin,
           x_fte_rec.ship_to_location_id,
           x_fte_rec.ship_tolerance_above,
           x_fte_rec.ship_tolerance_below,
           x_fte_rec.shipped_quantity,
           x_fte_rec.request_date,
           x_fte_rec.schedule_ship_date,
           x_fte_rec.organization_id,
           x_fte_rec.ordered_quantity,
           x_fte_rec.order_quantity_uom,
           x_fte_rec.cancelled_quantity,
           x_fte_rec.unit_list_price,
           x_fte_rec.preferred_grade,
           x_fte_rec.ordered_quantity2,
           x_fte_rec.ordered_quantity_uom2,
           x_fte_rec.requested_quantity2,
           x_fte_rec.cancelled_quantity2,
           x_fte_rec.requested_quantity_uom2,
           x_fte_rec.po_shipment_line_number,
           x_fte_rec.days_early_receipt_allowed,
           x_fte_rec.days_late_receipt_allowed,
           x_fte_rec.drop_ship_flag,
           x_fte_rec.qty_rcv_exception_code,
           x_fte_rec.closed_flag,
           x_fte_rec.closed_code,
           x_fte_rec.cancelled_flag,
           x_fte_rec.receipt_days_exception_code,
           x_fte_rec.enforce_ship_to_location_code,
           x_fte_rec.shipping_details_updated_on,
           x_fte_rec.carrier_id,    -- Others
           x_fte_rec.net_weight,
           x_fte_rec.weight_uom_code,
           x_fte_rec.volume,
           x_fte_rec.volume_uom_code
      FROM PO_HEADERS           POH,
           PO_LINES             POL,
           PO_LINE_LOCATIONS    POLL,
           PO_LINE_TYPES_B      PLT,
           ORG_FREIGHT_TL       FRT,
           MTL_SYSTEM_ITEMS_B   MSI,
           PO_DOCUMENT_TYPES_VL PDT,
           MTL_UNITS_OF_MEASURE MUOM,
           MTL_UNITS_OF_MEASURE MUOM1
     WHERE POH.po_header_id = p_header_id
       AND PDT.document_type_code = 'PO'
       AND PDT.document_subtype = POH.type_lookup_code
       AND POL.po_header_id = POH.po_header_id
       AND POLL.po_line_id = POL.po_line_id
       AND POL.po_line_id = NVL(p_line_id, POL.po_line_id)
       AND POLL.line_location_id
           = NVL(p_line_location_id, POLL.line_location_id)
       AND POL.line_type_id = PLT.line_type_id
       AND PLT.order_type_lookup_code = 'QUANTITY'
       AND FRT.freight_code (+) = POH.ship_via_lookup_code
       AND FRT.language (+) = USERENV('LANG')
       AND NVL(FRT.organization_id, POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MSI.inventory_item_id (+) = POL.item_id
       AND NVL(MSI.organization_id,  POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MUOM.unit_of_measure(+) = POL.unit_meas_lookup_code
       AND MUOM1.unit_of_measure(+) = POLL.secondary_unit_of_measure
       AND NVL(POLL.closed_code, 'OPEN') = 'FINALLY CLOSED';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
END;




-------------------------------------------------------------------------------
--Start of Comments
--Name: get_approved_release
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Get data for delivery record from Approved Blanket Release
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_header_id
--  Corresponding to po_release_id
--p_line_location_id
--  Corresponding to po_line_location_id
--IN OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--Testing:
--  Need to integrate FTE to implement the testing.
--End of Comments
-------------------------------------------------------------------------------


PROCEDURE get_approved_release
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
)
IS
l_api_name       CONSTANT VARCHAR2(100)    :=    'get_approved_release';
l_api_version    CONSTANT NUMBER           :=    1.0;

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
           (
               p_current_version_number => l_api_version,
               p_caller_version_number  => p_api_version,
               p_api_name               => l_api_name,
               p_pkg_name               => 'PO_DELREC_PVT'
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- The following is for query data for delivery record from:
    -- Approved Blanket Release

    --SQL What: Querying data from Approved Blanket Releases of quantity
    --SQL       based items.
    --SQL Where: MSI.inventory_item_id (+) = POL.item_id
    --SQL        NVL(MSI.organization_id, POLL.ship_to_organization_id)
    --SQL        = POLL.ship_to_organization_id
    --SQL        To get record for one-time item
    --SQL Why: Same as SQL What
    SELECT POR.po_release_id,
           POR.release_num,
           POR.shipping_control,
           POR.revision_num,
           'PO',    -- source code
           POH.po_header_id,
           POH.vendor_id,
           POH.vendor_site_id,
           POH.user_hold_flag,
           POH.freight_terms_lookup_code,
           POH.fob_lookup_code,
           POH.segment1,
           2,    -- stands for 'RELEASE'
           PDT.type_name,
           POH.org_id,
           POH.currency_code,
           POH.revision_num,
           POL.po_line_id,
           POL.item_id,
           POL.item_description,
           POL.hazard_class_id,
           POL.item_revision,
           POL.vendor_product_num,
           POL.line_num,
           DECODE(PLT.outside_operation_flag, 'Y', 'GB_OSP', 'GB'),
           POLL.line_location_id,
           POLL.country_of_origin_code,
           POLL.ship_to_location_id,
           POLL.qty_rcv_tolerance,
           POLL.receive_close_tolerance,
           POLL.quantity_shipped,
           POLL.need_by_date,
           POLL.promised_date,
           POLL.ship_to_organization_id,
           POLL.quantity,
           MUOM.uom_code,
           POLL.quantity_cancelled,
           POLL.price_override,
           POLL.preferred_grade,
           POLL.secondary_quantity,
           MUOM1.uom_code,
           POLL.secondary_quantity,
           POLL.secondary_quantity_cancelled,
           MUOM1.uom_code,
           POLL.shipment_num,
           POLL.days_early_receipt_allowed,
           POLL.days_late_receipt_allowed,
           POLL.drop_ship_flag,
           POLL.qty_rcv_exception_code,
           POLL.closed_flag,
           POLL.closed_code,
           POLL.cancel_flag,
           POLL.receipt_days_exception_code,
           POLL.enforce_ship_to_location_code,
           POLL.last_update_date,
           FRT.party_id,
           MSI.unit_weight,
           MSI.weight_uom_code,
           MSI.unit_volume,
           MSI.volume_uom_code
      BULK COLLECT INTO
           x_fte_rec.source_blanket_reference_id,    -- Release Header
           x_fte_rec.source_blanket_reference_num,
           x_fte_rec.shipping_control,
           x_fte_rec.release_revision,
           x_fte_rec.source_code,
           x_fte_rec.header_id,    -- PO Header
           x_fte_rec.vendor_id,
           x_fte_rec.ship_from_site_id,
           x_fte_rec.hold_code,
           x_fte_rec.freight_terms_code,
           x_fte_rec.fob_point_code,
           x_fte_rec.source_header_number,
           x_fte_rec.source_header_type_id,
           x_fte_rec.source_header_type_name,
           x_fte_rec.org_id,
           x_fte_rec.currency_code,
           x_fte_rec.po_revision,
           x_fte_rec.line_id,    -- Line
           x_fte_rec.inventory_item_id,
           x_fte_rec.item_description,
           x_fte_rec.hazard_class_id,
           x_fte_rec.revision,
           x_fte_rec.supplier_item_num,
           x_fte_rec.source_line_number,
           x_fte_rec.source_line_type_code,
           x_fte_rec.po_shipment_line_id,    -- Shipment
           x_fte_rec.country_of_origin,
           x_fte_rec.ship_to_location_id,
           x_fte_rec.ship_tolerance_above,
           x_fte_rec.ship_tolerance_below,
           x_fte_rec.shipped_quantity,
           x_fte_rec.request_date,
           x_fte_rec.schedule_ship_date,
           x_fte_rec.organization_id,
           x_fte_rec.ordered_quantity,
           x_fte_rec.order_quantity_uom,
           x_fte_rec.cancelled_quantity,
           x_fte_rec.unit_list_price,
           x_fte_rec.preferred_grade,
           x_fte_rec.ordered_quantity2,
           x_fte_rec.ordered_quantity_uom2,
           x_fte_rec.requested_quantity2,
           x_fte_rec.cancelled_quantity2,
           x_fte_rec.requested_quantity_uom2,
           x_fte_rec.po_shipment_line_number,
           x_fte_rec.days_early_receipt_allowed,
           x_fte_rec.days_late_receipt_allowed,
           x_fte_rec.drop_ship_flag,
           x_fte_rec.qty_rcv_exception_code,
           x_fte_rec.closed_flag,
           x_fte_rec.closed_code,
           x_fte_rec.cancelled_flag,
           x_fte_rec.receipt_days_exception_code,
           x_fte_rec.enforce_ship_to_location_code,
           x_fte_rec.shipping_details_updated_on,
           x_fte_rec.carrier_id,    -- Others
           x_fte_rec.net_weight,
           x_fte_rec.weight_uom_code,
           x_fte_rec.volume,
           x_fte_rec.volume_uom_code
      FROM PO_RELEASES          POR,
           PO_HEADERS           POH,
           PO_LINES             POL,
           PO_LINE_LOCATIONS    POLL,
           PO_LINE_TYPES_B      PLT,
           ORG_FREIGHT_TL       FRT,
           MTL_SYSTEM_ITEMS_B   MSI,
           PO_DOCUMENT_TYPES_VL PDT,
           MTL_UNITS_OF_MEASURE MUOM,
           MTL_UNITS_OF_MEASURE MUOM1
     WHERE POR.po_release_id = p_header_id
       AND POH.po_header_id = POR.po_header_id
       AND POL.po_header_id = POH.po_header_id
       AND POLL.po_line_id = POL.po_line_id
       AND POLL.po_release_id = POR.po_release_id
       AND PDT.document_type_code = 'PA'
       AND PDT.document_subtype = POR.release_type
       AND POLL.line_location_id
           = NVL(p_line_location_id, POLL.line_location_id)
       AND POL.LINE_TYPE_ID = PLT.LINE_TYPE_ID
       AND PLT.ORDER_TYPE_LOOKUP_CODE = 'QUANTITY'
       AND FRT.freight_code (+) = POH.ship_via_lookup_code
       AND FRT.language (+) = USERENV('LANG')
       AND NVL(FRT.organization_id, POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MSI.inventory_item_id (+) = POL.item_id
       AND NVL(MSI.organization_id, POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MUOM.unit_of_measure(+) = POL.unit_meas_lookup_code
       AND MUOM1.unit_of_measure(+) = POLL.secondary_unit_of_measure
       AND NVL(POLL.approved_flag, 'N') = 'Y'
       AND NVL(POLL.cancel_flag, 'N') <> 'Y'; -- Bug 3581992

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
END;





-------------------------------------------------------------------------------
--Start of Comments
--Name: get_cancelled_release
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Get data for delivery record from Cacelled Blanket Release
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_header_id
--  Corresponding to po_release_id
--p_line_location_id
--  Corresponding to po_line_location_id
--IN OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--Testing:
--  Need to integrate FTE to implement the testing.
--End of Comments
-------------------------------------------------------------------------------


PROCEDURE get_cancelled_release
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
)
IS
l_api_name       CONSTANT VARCHAR2(100)    :=    'get_cancelled_release';
l_api_version    CONSTANT NUMBER           :=    1.0;

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
           (
               p_current_version_number => l_api_version,
               p_caller_version_number  => p_api_version,
               p_api_name               => l_api_name,
               p_pkg_name               => 'PO_DELREC_PVT'
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- The following is for query data for delivery record from:
    -- Cancelled Blanket Release

    --SQL What: Querying data from Cancelled Blanket Releases of quantity
    --SQL       based items.
    --SQL Where: MSI.inventory_item_id (+) = POL.item_id
    --SQL        NVL(MSI.organization_id, POLL.ship_to_organization_id)
    --SQL        = POLL.ship_to_organization_id
    --SQL        To get record for one-time item
    --SQL Why: Same as SQL What
    SELECT POR.po_release_id,
           POR.release_num,
           POR.shipping_control,
           POR.revision_num,
           'PO',    -- source code
           POH.po_header_id,
           POH.vendor_id,
           POH.vendor_site_id,
           POH.user_hold_flag,
           POH.freight_terms_lookup_code,
           POH.fob_lookup_code,
           POH.segment1,
           2,    -- stands for 'RELEASE'
           PDT.type_name,
           POH.org_id,
           POH.currency_code,
           POH.revision_num,
           POL.po_line_id,
           POL.item_id,
           POL.item_description,
           POL.hazard_class_id,
           POL.item_revision,
           POL.vendor_product_num,
           POL.line_num,
           DECODE(PLT.outside_operation_flag, 'Y', 'GB_OSP', 'GB'),
           POLL.line_location_id,
           POLL.country_of_origin_code,
           POLL.ship_to_location_id,
           POLL.qty_rcv_tolerance,
           POLL.receive_close_tolerance,
           POLL.quantity_shipped,
           POLL.need_by_date,
           POLL.promised_date,
           POLL.ship_to_organization_id,
           POLL.quantity,
           MUOM.uom_code,
           POLL.quantity_cancelled,
           POLL.price_override,
           POLL.preferred_grade,
           POLL.secondary_quantity,
           MUOM1.uom_code,
           POLL.secondary_quantity,
           POLL.secondary_quantity_cancelled,
           MUOM1.uom_code,
           POLL.shipment_num,
           POLL.days_early_receipt_allowed,
           POLL.days_late_receipt_allowed,
           POLL.drop_ship_flag,
           POLL.qty_rcv_exception_code,
           POLL.closed_flag,
           POLL.closed_code,
           POLL.cancel_flag,
           POLL.receipt_days_exception_code,
           POLL.enforce_ship_to_location_code,
           POLL.last_update_date,
           FRT.party_id,
           MSI.unit_weight,
           MSI.weight_uom_code,
           MSI.unit_volume,
           MSI.volume_uom_code
      BULK COLLECT INTO
           x_fte_rec.source_blanket_reference_id,    -- Release Header
           x_fte_rec.source_blanket_reference_num,
           x_fte_rec.shipping_control,
           x_fte_rec.release_revision,
           x_fte_rec.source_code,
           x_fte_rec.header_id,    -- PO Header
           x_fte_rec.vendor_id,
           x_fte_rec.ship_from_site_id,
           x_fte_rec.hold_code,
           x_fte_rec.freight_terms_code,
           x_fte_rec.fob_point_code,
           x_fte_rec.source_header_number,
           x_fte_rec.source_header_type_id,
           x_fte_rec.source_header_type_name,
           x_fte_rec.org_id,
           x_fte_rec.currency_code,
           x_fte_rec.po_revision,
           x_fte_rec.line_id,    -- Line
           x_fte_rec.inventory_item_id,
           x_fte_rec.item_description,
           x_fte_rec.hazard_class_id,
           x_fte_rec.revision,
           x_fte_rec.supplier_item_num,
           x_fte_rec.source_line_number,
           x_fte_rec.source_line_type_code,
           x_fte_rec.po_shipment_line_id,    -- Shipment
           x_fte_rec.country_of_origin,
           x_fte_rec.ship_to_location_id,
           x_fte_rec.ship_tolerance_above,
           x_fte_rec.ship_tolerance_below,
           x_fte_rec.shipped_quantity,
           x_fte_rec.request_date,
           x_fte_rec.schedule_ship_date,
           x_fte_rec.organization_id,
           x_fte_rec.ordered_quantity,
           x_fte_rec.order_quantity_uom,
           x_fte_rec.cancelled_quantity,
           x_fte_rec.unit_list_price,
           x_fte_rec.preferred_grade,
           x_fte_rec.ordered_quantity2,
           x_fte_rec.ordered_quantity_uom2,
           x_fte_rec.requested_quantity2,
           x_fte_rec.cancelled_quantity2,
           x_fte_rec.requested_quantity_uom2,
           x_fte_rec.po_shipment_line_number,
           x_fte_rec.days_early_receipt_allowed,
           x_fte_rec.days_late_receipt_allowed,
           x_fte_rec.drop_ship_flag,
           x_fte_rec.qty_rcv_exception_code,
           x_fte_rec.closed_flag,
           x_fte_rec.closed_code,
           x_fte_rec.cancelled_flag,
           x_fte_rec.receipt_days_exception_code,
           x_fte_rec.enforce_ship_to_location_code,
           x_fte_rec.shipping_details_updated_on,
           x_fte_rec.carrier_id,    -- Others
           x_fte_rec.net_weight,
           x_fte_rec.weight_uom_code,
           x_fte_rec.volume,
           x_fte_rec.volume_uom_code
      FROM PO_RELEASES          POR,
           PO_HEADERS           POH,
           PO_LINES             POL,
           PO_LINE_LOCATIONS    POLL,
           PO_LINE_TYPES_B      PLT,
           ORG_FREIGHT_TL       FRT,
           MTL_SYSTEM_ITEMS_B   MSI,
           PO_DOCUMENT_TYPES_VL PDT,
           MTL_UNITS_OF_MEASURE MUOM,
           MTL_UNITS_OF_MEASURE MUOM1
     WHERE POR.po_release_id = p_header_id
       AND POH.po_header_id = POR.po_header_id
       AND POL.po_header_id = POH.po_header_id
       AND POLL.po_line_id = POL.po_line_id
       AND POLL.po_release_id = POR.po_release_id
       AND PDT.document_type_code = 'PA'
       AND PDT.document_subtype = POR.release_type
       AND POLL.line_location_id
           = NVL(p_line_location_id, POLL.line_location_id)
       AND POL.LINE_TYPE_ID = PLT.LINE_TYPE_ID
       AND PLT.ORDER_TYPE_LOOKUP_CODE = 'QUANTITY'
       AND FRT.freight_code (+) = POH.ship_via_lookup_code
       AND FRT.language (+) = USERENV('LANG')
       AND NVL(FRT.organization_id, POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MSI.inventory_item_id (+) = POL.item_id
       AND NVL(MSI.organization_id, POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MUOM.unit_of_measure(+) = POL.unit_meas_lookup_code
       AND MUOM1.unit_of_measure(+) = POLL.secondary_unit_of_measure
       AND NVL(POLL.cancel_flag, 'N') = 'Y';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
END;




-------------------------------------------------------------------------------
--Start of Comments
--Name: get_opened_release
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Get data for delivery record from Opened Blanket Release
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_header_id
--  Corresponding to po_release_id
--p_line_location_id
--  Corresponding to po_line_location_id
--IN OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--Testing:
--  Need to integrate FTE to implement the testing.
--End of Comments
-------------------------------------------------------------------------------


PROCEDURE get_opened_release
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
)
IS
l_api_name       CONSTANT VARCHAR2(100)    :=    'get_opened_release';
l_api_version    CONSTANT NUMBER           :=    1.0;

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
           (
               p_current_version_number => l_api_version,
               p_caller_version_number  => p_api_version,
               p_api_name               => l_api_name,
               p_pkg_name               => 'PO_DELREC_PVT'
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- The following is for query data for delivery record from:
    -- Opened Blanket Release

    --SQL What: Querying data from Opened Blanket Releases of quantity
    --SQL       based items.
    --SQL Where: MSI.inventory_item_id (+) = POL.item_id
    --SQL        NVL(MSI.organization_id, POLL.ship_to_organization_id)
    --SQL        = POLL.ship_to_organization_id
    --SQL        To get record for one-time item
    --SQL Why: Same as SQL What
    SELECT POR.po_release_id,
           POR.release_num,
           POR.shipping_control,
           POR.revision_num,
           'PO',    -- source code
           POH.po_header_id,
           POH.vendor_id,
           POH.vendor_site_id,
           POH.user_hold_flag,
           POH.freight_terms_lookup_code,
           POH.fob_lookup_code,
           POH.segment1,
           2,    -- stands for 'RELEASE'
           PDT.type_name,
           POH.org_id,
           POH.currency_code,
           POH.revision_num,
           POL.po_line_id,
           POL.item_id,
           POL.item_description,
           POL.hazard_class_id,
           POL.item_revision,
           POL.vendor_product_num,
           POL.line_num,
           DECODE(PLT.outside_operation_flag, 'Y', 'GB_OSP', 'GB'),
           POLL.line_location_id,
           POLL.country_of_origin_code,
           POLL.ship_to_location_id,
           POLL.qty_rcv_tolerance,
           POLL.receive_close_tolerance,
           POLL.quantity_shipped,
           POLL.need_by_date,
           POLL.promised_date,
           POLL.ship_to_organization_id,
           POLL.quantity,
           MUOM.uom_code,
           POLL.quantity_cancelled,
           POLL.price_override,
           POLL.preferred_grade,
           POLL.secondary_quantity,
           MUOM1.uom_code,
           POLL.secondary_quantity,
           POLL.secondary_quantity_cancelled,
           MUOM1.uom_code,
           POLL.shipment_num,
           POLL.days_early_receipt_allowed,
           POLL.days_late_receipt_allowed,
           POLL.drop_ship_flag,
           POLL.qty_rcv_exception_code,
           POLL.closed_flag,
           POLL.closed_code,
           POLL.cancel_flag,
           POLL.receipt_days_exception_code,
           POLL.enforce_ship_to_location_code,
           POLL.last_update_date,
           FRT.party_id,
           MSI.unit_weight,
           MSI.weight_uom_code,
           MSI.unit_volume,
           MSI.volume_uom_code
      BULK COLLECT INTO
           x_fte_rec.source_blanket_reference_id,    -- Release Header
           x_fte_rec.source_blanket_reference_num,
           x_fte_rec.shipping_control,
           x_fte_rec.release_revision,
           x_fte_rec.source_code,
           x_fte_rec.header_id,    -- PO Header
           x_fte_rec.vendor_id,
           x_fte_rec.ship_from_site_id,
           x_fte_rec.hold_code,
           x_fte_rec.freight_terms_code,
           x_fte_rec.fob_point_code,
           x_fte_rec.source_header_number,
           x_fte_rec.source_header_type_id,
           x_fte_rec.source_header_type_name,
           x_fte_rec.org_id,
           x_fte_rec.currency_code,
           x_fte_rec.po_revision,
           x_fte_rec.line_id,    -- Line
           x_fte_rec.inventory_item_id,
           x_fte_rec.item_description,
           x_fte_rec.hazard_class_id,
           x_fte_rec.revision,
           x_fte_rec.supplier_item_num,
           x_fte_rec.source_line_number,
           x_fte_rec.source_line_type_code,
           x_fte_rec.po_shipment_line_id,    -- Shipment
           x_fte_rec.country_of_origin,
           x_fte_rec.ship_to_location_id,
           x_fte_rec.ship_tolerance_above,
           x_fte_rec.ship_tolerance_below,
           x_fte_rec.shipped_quantity,
           x_fte_rec.request_date,
           x_fte_rec.schedule_ship_date,
           x_fte_rec.organization_id,
           x_fte_rec.ordered_quantity,
           x_fte_rec.order_quantity_uom,
           x_fte_rec.cancelled_quantity,
           x_fte_rec.unit_list_price,
           x_fte_rec.preferred_grade,
           x_fte_rec.ordered_quantity2,
           x_fte_rec.ordered_quantity_uom2,
           x_fte_rec.requested_quantity2,
           x_fte_rec.cancelled_quantity2,
           x_fte_rec.requested_quantity_uom2,
           x_fte_rec.po_shipment_line_number,
           x_fte_rec.days_early_receipt_allowed,
           x_fte_rec.days_late_receipt_allowed,
           x_fte_rec.drop_ship_flag,
           x_fte_rec.qty_rcv_exception_code,
           x_fte_rec.closed_flag,
           x_fte_rec.closed_code,
           x_fte_rec.cancelled_flag,
           x_fte_rec.receipt_days_exception_code,
           x_fte_rec.enforce_ship_to_location_code,
           x_fte_rec.shipping_details_updated_on,
           x_fte_rec.carrier_id,    -- Others
           x_fte_rec.net_weight,
           x_fte_rec.weight_uom_code,
           x_fte_rec.volume,
           x_fte_rec.volume_uom_code
      FROM PO_RELEASES          POR,
           PO_HEADERS           POH,
           PO_LINES             POL,
           PO_LINE_LOCATIONS    POLL,
           PO_LINE_TYPES_B      PLT,
           ORG_FREIGHT_TL       FRT,
           MTL_SYSTEM_ITEMS_B   MSI,
           PO_DOCUMENT_TYPES_VL PDT,
           MTL_UNITS_OF_MEASURE MUOM,
           MTL_UNITS_OF_MEASURE MUOM1
     WHERE POR.po_release_id = p_header_id
       AND POH.po_header_id = POR.po_header_id
       AND POL.po_header_id = POH.po_header_id
       AND POLL.po_line_id = POL.po_line_id
       AND POLL.po_release_id = POR.po_release_id
       AND PDT.document_type_code = 'PA'
       AND PDT.document_subtype = POR.release_type
       AND POLL.line_location_id
           = NVL(p_line_location_id, POLL.line_location_id)
       AND POL.LINE_TYPE_ID = PLT.LINE_TYPE_ID
       AND PLT.ORDER_TYPE_LOOKUP_CODE = 'QUANTITY'
       AND FRT.freight_code (+) = POH.ship_via_lookup_code
       AND FRT.language (+) = USERENV('LANG')
       AND NVL(FRT.organization_id, POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MSI.inventory_item_id (+) = POL.item_id
       AND NVL(MSI.organization_id, POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MUOM.unit_of_measure(+) = POL.unit_meas_lookup_code
       AND MUOM1.unit_of_measure(+) = POLL.secondary_unit_of_measure
       AND NVL(POLL.closed_code, 'OPEN') = 'OPEN'
       AND NVL(POLL.cancel_flag, 'N') <> 'Y'; -- Bug 3581992

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
END;




-------------------------------------------------------------------------------
--Start of Comments
--Name: get_closed_release
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Get data for delivery record from Closed Blanket Release
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_header_id
--  Corresponding to po_release_id
--p_line_location_id
--  Corresponding to po_line_location_id
--IN OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--Testing:
--  Need to integrate FTE to implement the testing.
--End of Comments
-------------------------------------------------------------------------------


PROCEDURE get_closed_release
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
)
IS
l_api_name       CONSTANT VARCHAR2(100)    :=    'get_closed_release';
l_api_version    CONSTANT NUMBER           :=    1.0;

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
           (
               p_current_version_number => l_api_version,
               p_caller_version_number  => p_api_version,
               p_api_name               => l_api_name,
               p_pkg_name               => 'PO_DELREC_PVT'
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- The following is for query data for delivery record from:
    -- Closed Blanket Release

    --SQL What: Querying data from Closed Blanket Releases of quantity
    --SQL       based items.
    --SQL Where: MSI.inventory_item_id (+) = POL.item_id
    --SQL        NVL(MSI.organization_id, POLL.ship_to_organization_id)
    --SQL        = POLL.ship_to_organization_id
    --SQL        To get record for one-time item
    --SQL Why: Same as SQL What
    SELECT POR.po_release_id,
           POR.release_num,
           POR.shipping_control,
           POR.revision_num,
           'PO',    -- source code
           POH.po_header_id,
           POH.vendor_id,
           POH.vendor_site_id,
           POH.user_hold_flag,
           POH.freight_terms_lookup_code,
           POH.fob_lookup_code,
           POH.segment1,
           2,    -- stands for 'RELEASE'
           PDT.type_name,
           POH.org_id,
           POH.currency_code,
           POH.revision_num,
           POL.po_line_id,
           POL.item_id,
           POL.item_description,
           POL.hazard_class_id,
           POL.item_revision,
           POL.vendor_product_num,
           POL.line_num,
           DECODE(PLT.outside_operation_flag, 'Y', 'GB_OSP', 'GB'),
           POLL.line_location_id,
           POLL.country_of_origin_code,
           POLL.ship_to_location_id,
           POLL.qty_rcv_tolerance,
           POLL.receive_close_tolerance,
           POLL.quantity_shipped,
           POLL.need_by_date,
           POLL.promised_date,
           POLL.ship_to_organization_id,
           POLL.quantity,
           MUOM.uom_code,
           POLL.quantity_cancelled,
           POLL.price_override,
           POLL.preferred_grade,
           POLL.secondary_quantity,
           MUOM1.uom_code,
           POLL.secondary_quantity,
           POLL.secondary_quantity_cancelled,
           MUOM1.uom_code,
           POLL.shipment_num,
           POLL.days_early_receipt_allowed,
           POLL.days_late_receipt_allowed,
           POLL.drop_ship_flag,
           POLL.qty_rcv_exception_code,
           POLL.closed_flag,
           POLL.closed_code,
           POLL.cancel_flag,
           POLL.receipt_days_exception_code,
           POLL.enforce_ship_to_location_code,
           POLL.last_update_date,
           FRT.party_id,
           MSI.unit_weight,
           MSI.weight_uom_code,
           MSI.unit_volume,
           MSI.volume_uom_code
      BULK COLLECT INTO
           x_fte_rec.source_blanket_reference_id,    -- Release Header
           x_fte_rec.source_blanket_reference_num,
           x_fte_rec.shipping_control,
           x_fte_rec.release_revision,
           x_fte_rec.source_code,
           x_fte_rec.header_id,    -- PO Header
           x_fte_rec.vendor_id,
           x_fte_rec.ship_from_site_id,
           x_fte_rec.hold_code,
           x_fte_rec.freight_terms_code,
           x_fte_rec.fob_point_code,
           x_fte_rec.source_header_number,
           x_fte_rec.source_header_type_id,
           x_fte_rec.source_header_type_name,
           x_fte_rec.org_id,
           x_fte_rec.currency_code,
           x_fte_rec.po_revision,
           x_fte_rec.line_id,    -- Line
           x_fte_rec.inventory_item_id,
           x_fte_rec.item_description,
           x_fte_rec.hazard_class_id,
           x_fte_rec.revision,
           x_fte_rec.supplier_item_num,
           x_fte_rec.source_line_number,
           x_fte_rec.source_line_type_code,
           x_fte_rec.po_shipment_line_id,    -- Shipment
           x_fte_rec.country_of_origin,
           x_fte_rec.ship_to_location_id,
           x_fte_rec.ship_tolerance_above,
           x_fte_rec.ship_tolerance_below,
           x_fte_rec.shipped_quantity,
           x_fte_rec.request_date,
           x_fte_rec.schedule_ship_date,
           x_fte_rec.organization_id,
           x_fte_rec.ordered_quantity,
           x_fte_rec.order_quantity_uom,
           x_fte_rec.cancelled_quantity,
           x_fte_rec.unit_list_price,
           x_fte_rec.preferred_grade,
           x_fte_rec.ordered_quantity2,
           x_fte_rec.ordered_quantity_uom2,
           x_fte_rec.requested_quantity2,
           x_fte_rec.cancelled_quantity2,
           x_fte_rec.requested_quantity_uom2,
           x_fte_rec.po_shipment_line_number,
           x_fte_rec.days_early_receipt_allowed,
           x_fte_rec.days_late_receipt_allowed,
           x_fte_rec.drop_ship_flag,
           x_fte_rec.qty_rcv_exception_code,
           x_fte_rec.closed_flag,
           x_fte_rec.closed_code,
           x_fte_rec.cancelled_flag,
           x_fte_rec.receipt_days_exception_code,
           x_fte_rec.enforce_ship_to_location_code,
           x_fte_rec.shipping_details_updated_on,
           x_fte_rec.carrier_id,    -- Others
           x_fte_rec.net_weight,
           x_fte_rec.weight_uom_code,
           x_fte_rec.volume,
           x_fte_rec.volume_uom_code
      FROM PO_RELEASES          POR,
           PO_HEADERS           POH,
           PO_LINES             POL,
           PO_LINE_LOCATIONS    POLL,
           PO_LINE_TYPES_B      PLT,
           ORG_FREIGHT_TL       FRT,
           MTL_SYSTEM_ITEMS_B   MSI,
           PO_DOCUMENT_TYPES_VL PDT,
           MTL_UNITS_OF_MEASURE MUOM,
           MTL_UNITS_OF_MEASURE MUOM1
     WHERE POR.po_release_id = p_header_id
       AND POH.po_header_id = POR.po_header_id
       AND POL.po_header_id = POH.po_header_id
       AND POLL.po_line_id = POL.po_line_id
       AND POLL.po_release_id = POR.po_release_id
       AND PDT.document_type_code = 'PA'
       AND PDT.document_subtype = POR.release_type
       AND POLL.line_location_id
           = NVL(p_line_location_id, POLL.line_location_id)
       AND POL.LINE_TYPE_ID = PLT.LINE_TYPE_ID
       AND PLT.ORDER_TYPE_LOOKUP_CODE = 'QUANTITY'
       AND FRT.freight_code (+) = POH.ship_via_lookup_code
       AND FRT.language (+) = USERENV('LANG')
       AND NVL(FRT.organization_id, POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MSI.inventory_item_id (+) = POL.item_id
       AND NVL(MSI.organization_id, POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MUOM.unit_of_measure(+) = POL.unit_meas_lookup_code
       AND MUOM1.unit_of_measure(+) = POLL.secondary_unit_of_measure
       AND NVL(POLL.closed_code, 'OPEN') IN ('CLOSED', 'CLOSED FOR RECEIVING')
       AND NVL(POLL.cancel_flag, 'N') <> 'Y'; -- Bug 3581992

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
END;




-------------------------------------------------------------------------------
--Start of Comments
--Name: get_finally_closed_release
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Get data for delivery record from Finally Closed Blanket Release
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_header_id
--  Corresponding to po_release_id
--p_line_location_id
--  Corresponding to po_line_location_id
--IN OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--Testing:
--  Need to integrate FTE to implement the testing.
--End of Comments
-------------------------------------------------------------------------------




PROCEDURE get_finally_closed_release
(
    p_api_version      IN               NUMBER,
    x_return_status    IN OUT NOCOPY    VARCHAR2,
    p_header_id        IN               NUMBER,
    p_line_location_id IN               NUMBER,
    x_fte_rec          IN OUT NOCOPY    OE_WSH_BULK_GRP.Line_Rec_Type
)
IS
l_api_name       CONSTANT VARCHAR2(100)    :=    'get_finally_closed_release';
l_api_version    CONSTANT NUMBER           :=    1.0;

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
           (
               p_current_version_number => l_api_version,
               p_caller_version_number  => p_api_version,
               p_api_name               => l_api_name,
               p_pkg_name               => 'PO_DELREC_PVT'
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- The following is for query data for delivery record from:
    --Finally Closed Blanket Release

    --SQL What: Querying data from Finally Closed Blanket Releases of quantity
    --SQL       based items.
    --SQL Where: MSI.inventory_item_id (+) = POL.item_id
    --SQL        NVL(MSI.organization_id, POLL.ship_to_organization_id)
    --SQL        = POLL.ship_to_organization_id
    --SQL        To get record for one-time item
    --SQL Why: Same as SQL What
    SELECT POR.po_release_id,
           POR.release_num,
           POR.shipping_control,
           POR.revision_num,
           'PO',    -- source code
           POH.po_header_id,
           POH.vendor_id,
           POH.vendor_site_id,
           POH.user_hold_flag,
           POH.freight_terms_lookup_code,
           POH.fob_lookup_code,
           POH.segment1,
           2,    -- stands for 'RELEASE'
           PDT.type_name,
           POH.org_id,
           POH.currency_code,
           POH.revision_num,
           POL.po_line_id,
           POL.item_id,
           POL.item_description,
           POL.hazard_class_id,
           POL.item_revision,
           POL.vendor_product_num,
           POL.line_num,
           DECODE(PLT.outside_operation_flag, 'Y', 'GB_OSP', 'GB'),
           POLL.line_location_id,
           POLL.country_of_origin_code,
           POLL.ship_to_location_id,
           POLL.qty_rcv_tolerance,
           POLL.receive_close_tolerance,
           POLL.quantity_shipped,
           POLL.need_by_date,
           POLL.promised_date,
           POLL.ship_to_organization_id,
           POLL.quantity,
           MUOM.uom_code,
           POLL.quantity_cancelled,
           POLL.price_override,
           POLL.preferred_grade,
           POLL.secondary_quantity,
           MUOM1.uom_code,
           POLL.secondary_quantity,
           POLL.secondary_quantity_cancelled,
           MUOM1.uom_code,
           POLL.shipment_num,
           POLL.days_early_receipt_allowed,
           POLL.days_late_receipt_allowed,
           POLL.drop_ship_flag,
           POLL.qty_rcv_exception_code,
           POLL.closed_flag,
           POLL.closed_code,
           POLL.cancel_flag,
           POLL.receipt_days_exception_code,
           POLL.enforce_ship_to_location_code,
           POLL.last_update_date,
           FRT.party_id,
           MSI.unit_weight,
           MSI.weight_uom_code,
           MSI.unit_volume,
           MSI.volume_uom_code
      BULK COLLECT INTO
           x_fte_rec.source_blanket_reference_id,    -- Release Header
           x_fte_rec.source_blanket_reference_num,
           x_fte_rec.shipping_control,
           x_fte_rec.release_revision,
           x_fte_rec.source_code,
           x_fte_rec.header_id,    -- PO Header
           x_fte_rec.vendor_id,
           x_fte_rec.ship_from_site_id,
           x_fte_rec.hold_code,
           x_fte_rec.freight_terms_code,
           x_fte_rec.fob_point_code,
           x_fte_rec.source_header_number,
           x_fte_rec.source_header_type_id,
           x_fte_rec.source_header_type_name,
           x_fte_rec.org_id,
           x_fte_rec.currency_code,
           x_fte_rec.po_revision,
           x_fte_rec.line_id,    -- Line
           x_fte_rec.inventory_item_id,
           x_fte_rec.item_description,
           x_fte_rec.hazard_class_id,
           x_fte_rec.revision,
           x_fte_rec.supplier_item_num,
           x_fte_rec.source_line_number,
           x_fte_rec.source_line_type_code,
           x_fte_rec.po_shipment_line_id,    -- Shipment
           x_fte_rec.country_of_origin,
           x_fte_rec.ship_to_location_id,
           x_fte_rec.ship_tolerance_above,
           x_fte_rec.ship_tolerance_below,
           x_fte_rec.shipped_quantity,
           x_fte_rec.request_date,
           x_fte_rec.schedule_ship_date,
           x_fte_rec.organization_id,
           x_fte_rec.ordered_quantity,
           x_fte_rec.order_quantity_uom,
           x_fte_rec.cancelled_quantity,
           x_fte_rec.unit_list_price,
           x_fte_rec.preferred_grade,
           x_fte_rec.ordered_quantity2,
           x_fte_rec.ordered_quantity_uom2,
           x_fte_rec.requested_quantity2,
           x_fte_rec.cancelled_quantity2,
           x_fte_rec.requested_quantity_uom2,
           x_fte_rec.po_shipment_line_number,
           x_fte_rec.days_early_receipt_allowed,
           x_fte_rec.days_late_receipt_allowed,
           x_fte_rec.drop_ship_flag,
           x_fte_rec.qty_rcv_exception_code,
           x_fte_rec.closed_flag,
           x_fte_rec.closed_code,
           x_fte_rec.cancelled_flag,
           x_fte_rec.receipt_days_exception_code,
           x_fte_rec.enforce_ship_to_location_code,
           x_fte_rec.shipping_details_updated_on,
           x_fte_rec.carrier_id,    -- Others
           x_fte_rec.net_weight,
           x_fte_rec.weight_uom_code,
           x_fte_rec.volume,
           x_fte_rec.volume_uom_code
      FROM PO_RELEASES          POR,
           PO_HEADERS           POH,
           PO_LINES             POL,
           PO_LINE_LOCATIONS    POLL,
           PO_LINE_TYPES_B      PLT,
           ORG_FREIGHT_TL       FRT,
           MTL_SYSTEM_ITEMS_B   MSI,
           PO_DOCUMENT_TYPES_VL PDT,
           MTL_UNITS_OF_MEASURE MUOM,
           MTL_UNITS_OF_MEASURE MUOM1
     WHERE POR.po_release_id = p_header_id
       AND POH.po_header_id = POR.po_header_id
       AND POL.po_header_id = POH.po_header_id
       AND POLL.po_line_id = POL.po_line_id
       AND POLL.po_release_id = POR.po_release_id
       AND PDT.document_type_code = 'PA'
       AND PDT.document_subtype = POR.release_type
       AND POLL.line_location_id
           = NVL(p_line_location_id, POLL.line_location_id)
       AND POL.LINE_TYPE_ID = PLT.LINE_TYPE_ID
       AND PLT.ORDER_TYPE_LOOKUP_CODE = 'QUANTITY'
       AND FRT.freight_code (+) = POH.ship_via_lookup_code
       AND FRT.language (+) = USERENV('LANG')
       AND NVL(FRT.organization_id, POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MSI.inventory_item_id (+) = POL.item_id
       AND NVL(MSI.organization_id, POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND MUOM.unit_of_measure(+) = POL.unit_meas_lookup_code
       AND MUOM1.unit_of_measure(+) = POLL.secondary_unit_of_measure
       AND NVL(POLL.closed_code, 'OPEN') = 'FINALLY CLOSED';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
END;

-- Bug 3581992 START
-------------------------------------------------------------------------------
--Start of Comments
--Name: debug_fte_rec
--Pre-reqs:
--  None.
--Modifies:
--  FND log
--Locks:
--  None.
--Function:
--  Prints out some attributes of the FTE record to the FND log for debugging
--  purposes.
--Parameters:
--IN:
--p_fte_rec
--  record that we will pass to the FTE API
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE debug_fte_rec
(
  p_fte_rec IN OE_WSH_BULK_GRP.Line_Rec_Type
) IS
  l_api_name CONSTANT VARCHAR2(30) := 'debug_fte_rec';
BEGIN
  IF (g_debug_stmt) AND (p_fte_rec.po_shipment_line_id IS NOT NULL) THEN
    PO_DEBUG.debug_begin ( c_log_head||l_api_name );

    FOR i IN 1..p_fte_rec.po_shipment_line_id.COUNT LOOP
      PO_DEBUG.debug_var (
        p_log_head => c_log_head||l_api_name,
        p_progress => '000',
        p_name => 'p_fte_rec.po_shipment_line_id('||i||')',
        p_value => p_fte_rec.po_shipment_line_id(i)
      );
    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    null; -- ignore errors
END;
-- Bug 3581992 END

END PO_DELREC_PVT;

/
