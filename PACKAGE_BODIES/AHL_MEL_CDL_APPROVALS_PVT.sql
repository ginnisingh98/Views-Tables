--------------------------------------------------------
--  DDL for Package Body AHL_MEL_CDL_APPROVALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MEL_CDL_APPROVALS_PVT" AS
/* $Header: AHLVMAPB.pls 120.4 2008/04/23 22:31:07 sracha ship $ */

--------------------
-- Common cursors --
--------------------
CURSOR get_mel_cdl_details
(
    p_mel_cdl_header_id number
)
IS
SELECT  pcn.name,
        hdr.pc_node_id,
        hdr.mel_cdl_type_code,
        hdr.revision,
        hdr.version_number,
        hdr.object_version_number,
        hdr.revision_date
FROM    ahl_mel_cdl_headers hdr, ahl_pc_nodes_b pcn
WHERE   pcn.pc_node_id = hdr.pc_node_id AND
        hdr.mel_cdl_header_id = p_mel_cdl_header_id;

-- get mel/cdl details for a NR.
CURSOR get_ue_mel_cdl_details
(
    p_unit_deferral_id IN NUMBER
)
IS
SELECT
        ue.unit_effectivity_id,
        ue.mel_cdl_type_code,
        ue.log_series_code,
        ue.log_series_number,
        mca.ATA_CODE,
        csi.serial_number,
        mtl.concatenated_segments item_number,
        cs.incident_number,
        cs.summary,
        udf.object_version_number
FROM    ahl_unit_deferrals_b udf, ahl_unit_effectivities_b ue,
        cs_incidents_all_vl cs, ahl_mel_cdl_ata_sequences mca, csi_item_instances csi,
        jtf_notes_vl note, mtl_system_items_kfv mtl
WHERE   udf.unit_effectivity_id = ue.unit_effectivity_id
  AND   ue.csi_item_instance_id = csi.instance_id
  AND   ue.cs_incident_id = cs.incident_id
  AND   udf.ata_sequence_id = mca.MEL_CDL_ATA_SEQUENCE_ID
  AND   note.source_object_code(+) = 'AHL_MEL_CDL'
  AND   note.source_object_id(+) = mca.MEL_CDL_ATA_SEQUENCE_ID
  AND   csi.inventory_item_id = mtl.inventory_item_id
  AND   csi.inv_master_organization_id = mtl.organization_id
  AND   udf.unit_deferral_id = p_unit_deferral_id;


------------------------------------
-- Common constants and variables --
------------------------------------
l_dummy_varchar             VARCHAR2(1);
l_mel_cdl_rec               get_mel_cdl_details%rowtype;
l_ue_mel_cdl_details_rec    get_ue_mel_cdl_details%ROWTYPE;

G_DEFERRAL_REJECTED         CONSTANT VARCHAR2(30) := 'DEFERRAL_REJECTED';

----------------------
-- Local Procedures --
----------------------
-- procedure to revert NR status and workorder status.
PROCEDURE NR_Rollback_Status (p_unit_deferral_id  IN NUMBER,
                              p_unit_deferral_ovn IN NUMBER,
                              p_new_status        IN NUMBER,
                              p_itemtype          IN VARCHAR2,
                              p_itemkey           IN VARCHAR2,
                              p_actid             IN NUMBER,
                              p_funcmode          IN VARCHAR2,
                              x_resultout         OUT NOCOPY VARCHAR2);

PROCEDURE SET_ACTIVITY_DETAILS
(
    itemtype        IN          VARCHAR2,
    itemkey         IN          VARCHAR2,
    actid           IN          NUMBER,
    funcmode        IN          VARCHAR2,
    resultout       OUT NOCOPY  VARCHAR2
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.SET_ACTIVITY_DETAILS';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_object_id                 NUMBER;
    l_object_ovn                NUMBER;
    l_object_details            AHL_GENERIC_APRV_PVT.OBJRECTYP;
    l_approval_rule_id          NUMBER;
    l_approver_seq              NUMBER;
    l_subject                   VARCHAR2(500);
    l_error_msg                 VARCHAR2(2000);

BEGIN

    FND_MSG_PUB.INITIALIZE;

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    l_object_id := wf_engine.getitemattrnumber
    (
        itemtype    => itemtype,
        itemkey     => itemkey,
        aname       => 'OBJECT_ID'
    );

    l_object_ovn := wf_engine.getitemattrnumber
    (
        itemtype    => itemtype,
        itemkey     => itemkey,
        aname       => 'OBJECT_VER'
    );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'OBJECT_ID='||l_object_id||' OBJECT_VER='||l_object_ovn
        );
    END IF;

    l_object_details.operating_unit_id := NULL;
    l_object_details.priority := 'STANDARD';

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN')
    THEN

        OPEN get_mel_cdl_details(l_object_id);
        FETCH get_mel_cdl_details into l_mel_cdl_rec;
        IF (get_mel_cdl_details%NOTFOUND OR l_mel_cdl_rec.object_version_number <> l_object_ovn)
        THEN
            CLOSE get_mel_cdl_details;

            fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_ID_INVALID');
            fnd_message.set_token('HRD_ID', l_object_id, false);
            fnd_msg_pub.add;

            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
            THEN
                fnd_log.message
                (
                    fnd_log.level_exception,
                    l_debug_module,
                    false
                );
            END IF;

            resultout := 'COMPLETE:ERROR';
            RAISE FND_API.G_EXC_ERROR;

        END IF;
        CLOSE get_mel_cdl_details;

        /* FORWARD_SUBJECT */
        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_FORWARD_SUBJ');
        fnd_message.set_token('HRD_ID',l_object_id, false);
        fnd_message.set_token('PCN',l_mel_cdl_rec.name, false);
        fnd_message.set_token('REV',l_mel_cdl_rec.revision, false);
        fnd_message.set_token('TYPE',l_mel_cdl_rec.mel_cdl_type_code, false);
        l_subject := fnd_message.get;

        wf_engine.setitemattrtext
        (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'FORWARD_SUBJECT',
            avalue   => l_subject
        );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_statement,
                l_debug_module,
                'FORWARD_SUBJECT='||l_subject
            );
        END IF;

        /* APPROVAL_SUBJECT */
        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_APPROVAL_SUBJ');
        fnd_message.set_token('HRD_ID',l_object_id, false);
        fnd_message.set_token('PCN',l_mel_cdl_rec.name, false);
        fnd_message.set_token('REV',l_mel_cdl_rec.revision, false);
        fnd_message.set_token('TYPE',l_mel_cdl_rec.mel_cdl_type_code, false);
        l_subject := fnd_message.get;

        wf_engine.setitemattrtext
        (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'APPROVAL_SUBJECT',
            avalue   => l_subject
        );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_statement,
                l_debug_module,
                'APPROVAL_SUBJECT='||l_subject
            );
        END IF;

        /* REJECT_SUBJECT */
        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_REJECT_SUBJ');
        fnd_message.set_token('HRD_ID',l_object_id, false);
        fnd_message.set_token('PCN',l_mel_cdl_rec.name, false);
        fnd_message.set_token('REV',l_mel_cdl_rec.revision, false);
        fnd_message.set_token('TYPE',l_mel_cdl_rec.mel_cdl_type_code, false);
        l_subject := fnd_message.get;

        wf_engine.setitemattrtext
        (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'REJECT_SUBJECT',
            avalue   => l_subject
        );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_statement,
                l_debug_module,
                'REJECT_SUBJECT='||l_subject
            );
        END IF;

        /* APPROVED_SUBJECT */
        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_APPROVED_SUBJ');
        fnd_message.set_token('HRD_ID',l_object_id, false);
        fnd_message.set_token('PCN',l_mel_cdl_rec.name, false);
        fnd_message.set_token('REV',l_mel_cdl_rec.revision, false);
        fnd_message.set_token('TYPE',l_mel_cdl_rec.mel_cdl_type_code, false);
        l_subject := fnd_message.get;

        wf_engine.setitemattrtext
        (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'APPROVED_SUBJECT',
            avalue   => l_subject
        );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_statement,
                l_debug_module,
                'APPROVED_SUBJECT='||l_subject
            );
        END IF;

        /* FINAL_SUBJECT */
        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_FINAL_SUBJ');
        fnd_message.set_token('HRD_ID',l_object_id, false);
        fnd_message.set_token('PCN',l_mel_cdl_rec.name, false);
        fnd_message.set_token('REV',l_mel_cdl_rec.revision, false);
        fnd_message.set_token('TYPE',l_mel_cdl_rec.mel_cdl_type_code, false);
        l_subject := fnd_message.get;

        wf_engine.setitemattrtext
        (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'FINAL_SUBJECT',
            avalue   => l_subject
        );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_statement,
                l_debug_module,
                'FINAL_SUBJECT='||l_subject
            );
        END IF;

        /* REMIND_SUBJECT */
        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_REMIND_SUBJ');
        fnd_message.set_token('HRD_ID',l_object_id, false);
        fnd_message.set_token('PCN',l_mel_cdl_rec.name, false);
        fnd_message.set_token('REV',l_mel_cdl_rec.revision, false);
        fnd_message.set_token('TYPE',l_mel_cdl_rec.mel_cdl_type_code, false);
        l_subject := fnd_message.get;

        wf_engine.setitemattrtext
        (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'REMIND_SUBJECT',
            avalue   => l_subject
        );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_statement,
                l_debug_module,
                'REMIND_SUBJECT='||l_subject
            );
        END IF;

        /* ERROR_SUBJECT */
        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_ERROR_SUBJ');
        fnd_message.set_token('HRD_ID',l_object_id, false);
        fnd_message.set_token('PCN',l_mel_cdl_rec.name, false);
        fnd_message.set_token('REV',l_mel_cdl_rec.revision, false);
        fnd_message.set_token('TYPE',l_mel_cdl_rec.mel_cdl_type_code, false);
        l_subject := fnd_message.get;

        wf_engine.setitemattrtext
        (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'ERROR_SUBJECT',
            avalue   => l_subject
        );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_statement,
                l_debug_module,
                'ERROR_SUBJECT='||l_subject
            );
        END IF;

        /* Getting approver details */
        AHL_GENERIC_APRV_PVT.GET_APPROVAL_DETAILS
        (
            p_object            => G_APPR_OBJ,
            p_approval_type     => G_APPR_TYPE,
            p_object_details    => l_object_details,
            x_approval_rule_id  => l_approval_rule_id,
            x_approver_seq      => l_approver_seq,
            x_return_status     => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_SUCCESS
        THEN
            wf_engine.setitemattrnumber
            (
                itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'RULE_ID',
                avalue   => l_approval_rule_id
            );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
                fnd_log.string
                (
                    fnd_log.level_statement,
                    l_debug_module,
                    'RULE_ID='||l_approval_rule_id
                );
            END IF;

            wf_engine.setitemattrnumber
            (
                itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'APPROVER_SEQ',
                avalue   => l_approver_seq
            );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
                fnd_log.string
                (
                    fnd_log.level_statement,
                    l_debug_module,
                    'APPROVER_SEQ='||l_approver_seq
                );
            END IF;

            resultout := 'COMPLETE:SUCCESS';
            RETURN;
        ELSE
            resultout := 'COMPLETE:ERROR';
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL')
    THEN
        resultout := 'COMPLETE:';
        RETURN;
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT')
    THEN
        resultout := 'COMPLETE:';
        RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => itemtype,
            p_itemkey           => itemkey,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'SET_ACTIVITY_DETAILS',
            itemtype,
            itemkey,
            actid,
            funcmode,
            l_error_msg
        );
        resultout := 'COMPLETE:ERROR';
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'SET_ACTIVITY_DETAILS',
            itemtype,
            itemkey,
            actid,
            'Unexpected Error! '||SUBSTR(SQLERRM,1,240)
        );
        RAISE;

END SET_ACTIVITY_DETAILS;

PROCEDURE NTF_FORWARD_FYI
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NTF_FORWARD_FYI';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_hyphen_pos1               NUMBER;
    l_item_type                 VARCHAR2(30);
    l_item_key                  VARCHAR2(30);
    l_approver                  VARCHAR2(30);
    l_body                      VARCHAR2(3500);
    l_object_type               VARCHAR2(30);
    l_object_id                 NUMBER;
    l_error_msg                 VARCHAR2(2000);

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    document_type := 'text/plain';

    -- parse document_id for the ':' dividing item type name from item key value
    l_hyphen_pos1 := INSTR (document_id, ':');
    l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
    l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

    l_object_type := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_TYPE'
    );

    l_object_id := wf_engine.getitemattrNumber
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_ID'
    );

    l_approver := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'APPROVER'
    );

    OPEN get_mel_cdl_details(l_object_id);
    FETCH get_mel_cdl_details into l_mel_cdl_rec;
    IF (get_mel_cdl_details%NOTFOUND)
    THEN
        CLOSE get_mel_cdl_details;

        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_ID_INVALID');
        fnd_message.set_token('HRD_ID', l_object_id, false);
        fnd_msg_pub.add;

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.message
            (
                fnd_log.level_exception,
                l_debug_module,
                false
            );
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    ELSE
        CLOSE get_mel_cdl_details;

        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_FYI_FWD');
        fnd_message.set_token('HRD_ID',l_object_id, false);
        fnd_message.set_token('PCN',l_mel_cdl_rec.name, false);
        fnd_message.set_token('REV',l_mel_cdl_rec.revision, false);
        fnd_message.set_token('TYPE',l_mel_cdl_rec.mel_cdl_type_code, false);
        fnd_message.set_token('APPR_NAME',l_approver, false);
        l_body := fnd_message.get;

    END IF;

    document := document || l_body;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'document='||document
        );
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    RETURN;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => l_item_type,
            p_itemkey           => l_item_key,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NTF_FORWARD_FYI',
            l_item_type,
            l_item_key,
            l_error_msg
        );
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NTF_FORWARD_FYI',
            l_item_type,
            l_item_key
        );
        RAISE;
END NTF_FORWARD_FYI;

PROCEDURE NTF_APPROVED_FYI
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NTF_APPROVED_FYI';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_hyphen_pos1               NUMBER;
    l_item_type                 VARCHAR2(30);
    l_item_key                  VARCHAR2(30);
    l_approver                  VARCHAR2(30);
    l_body                      VARCHAR2(3500);
    l_object_type               VARCHAR2(30);
    l_object_id                 NUMBER;
    l_error_msg                 VARCHAR2(2000);

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    document_type := 'text/plain';

    -- parse document_id for the ':' dividing item type name from item key value
    l_hyphen_pos1 := INSTR (document_id, ':');
    l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
    l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

    l_object_type := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_TYPE'
    );

    l_object_id := wf_engine.getitemattrNumber
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_ID'
    );

    l_approver := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'APPROVER'
    );

    OPEN get_mel_cdl_details(l_object_id);
    FETCH get_mel_cdl_details into l_mel_cdl_rec;
    IF (get_mel_cdl_details%NOTFOUND)
    THEN
        CLOSE get_mel_cdl_details;

        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_ID_INVALID');
        fnd_message.set_token('HRD_ID', l_object_id, false);
        fnd_msg_pub.add;

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.message
            (
                fnd_log.level_exception,
                l_debug_module,
                false
            );
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    ELSE
        CLOSE get_mel_cdl_details;

        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_FYI_APPRVD');
        fnd_message.set_token('HRD_ID',l_object_id, false);
        fnd_message.set_token('PCN',l_mel_cdl_rec.name, false);
        fnd_message.set_token('REV',l_mel_cdl_rec.revision, false);
        fnd_message.set_token('TYPE',l_mel_cdl_rec.mel_cdl_type_code, false);
        fnd_message.set_token('APPR_NAME',l_approver, false);
        l_body := fnd_message.get;

    END IF;

    document := document || l_body;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'document='||document
        );
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    RETURN;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => l_item_type,
            p_itemkey           => l_item_key,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NTF_APPROVED_FYI',
            l_item_type,
            l_item_key,
            l_error_msg
        );
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NTF_APPROVED_FYI',
            l_item_type,
            l_item_key
        );
        RAISE;
END NTF_APPROVED_FYI;

PROCEDURE NTF_FINAL_APPROVAL_FYI
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NTF_FINAL_APPROVAL_FYI';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_hyphen_pos1               NUMBER;
    l_item_type                 VARCHAR2(30);
    l_item_key                  VARCHAR2(30);
    l_body                      VARCHAR2(3500);
    l_object_type               VARCHAR2(30);
    l_object_id                 NUMBER;
    l_error_msg                 VARCHAR2(2000);

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    document_type := 'text/plain';

    -- parse document_id for the ':' dividing item type name from item key value
    l_hyphen_pos1 := INSTR (document_id, ':');
    l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
    l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

    l_object_type := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_TYPE'
    );

    l_object_id := wf_engine.getitemattrNumber
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_ID'
    );

    OPEN get_mel_cdl_details(l_object_id);
    FETCH get_mel_cdl_details into l_mel_cdl_rec;
    IF (get_mel_cdl_details%NOTFOUND)
    THEN
        CLOSE get_mel_cdl_details;

        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_ID_INVALID');
        fnd_message.set_token('HRD_ID', l_object_id, false);
        fnd_msg_pub.add;

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.message
            (
                fnd_log.level_exception,
                l_debug_module,
                false
            );
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    ELSE
        CLOSE get_mel_cdl_details;

        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_FYI_FINAL');
        fnd_message.set_token('HRD_ID',l_object_id, false);
        fnd_message.set_token('PCN',l_mel_cdl_rec.name, false);
        fnd_message.set_token('REV',l_mel_cdl_rec.revision, false);
        fnd_message.set_token('TYPE',l_mel_cdl_rec.mel_cdl_type_code, false);
        l_body := fnd_message.get;

    END IF;

    document := document || l_body;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'document='||document
        );
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    RETURN;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => l_item_type,
            p_itemkey           => l_item_key,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NTF_FINAL_APPROVAL_FYI',
            l_item_type,
            l_item_key,
            l_error_msg
        );
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NTF_FINAL_APPROVAL_FYI',
            l_item_type,
            l_item_key
        );
        RAISE;
END NTF_FINAL_APPROVAL_FYI;

PROCEDURE NTF_REJECTED_FYI
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NTF_REJECTED_FYI';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_hyphen_pos1               NUMBER;
    l_item_type                 VARCHAR2(30);
    l_item_key                  VARCHAR2(30);
    l_approver                  VARCHAR2(30);
    l_body                      VARCHAR2(3500);
    l_object_type               VARCHAR2(30);
    l_object_id                 NUMBER;
    l_error_msg                 VARCHAR2(2000);

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    document_type := 'text/plain';

    -- parse document_id for the ':' dividing item type name from item key value
    l_hyphen_pos1 := INSTR (document_id, ':');
    l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
    l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

    l_object_type := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_TYPE'
    );

    l_object_id := wf_engine.getitemattrNumber
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_ID'
    );

    l_approver := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'APPROVER'
    );

    OPEN get_mel_cdl_details(l_object_id);
    FETCH get_mel_cdl_details into l_mel_cdl_rec;
    IF (get_mel_cdl_details%NOTFOUND)
    THEN
        CLOSE get_mel_cdl_details;

        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_ID_INVALID');
        fnd_message.set_token('HRD_ID', l_object_id, false);
        fnd_msg_pub.add;

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.message
            (
                fnd_log.level_exception,
                l_debug_module,
                false
            );
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    ELSE
        CLOSE get_mel_cdl_details;

        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_FYI_RJCT');
        fnd_message.set_token('HRD_ID',l_object_id, false);
        fnd_message.set_token('PCN',l_mel_cdl_rec.name, false);
        fnd_message.set_token('REV',l_mel_cdl_rec.revision, false);
        fnd_message.set_token('TYPE',l_mel_cdl_rec.mel_cdl_type_code, false);
        fnd_message.set_token('APPR_NAME',l_approver, false);
        l_body := fnd_message.get;

    END IF;

    document := document || l_body;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'document='||document
        );
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    RETURN;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => l_item_type,
            p_itemkey           => l_item_key,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NTF_REJECTED_FYI',
            l_item_type,
            l_item_key,
            l_error_msg
        );
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NTF_REJECTED_FYI',
            l_item_type,
            l_item_key
        );
        RAISE;
END NTF_REJECTED_FYI;

PROCEDURE NTF_APPROVAL
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NTF_APPROVAL';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_hyphen_pos1               NUMBER;
    l_item_type                 VARCHAR2(30);
    l_item_key                  VARCHAR2(30);
    l_requester                 VARCHAR2(30);
    l_requester_note            VARCHAR2(4000);
    l_body                      VARCHAR2(3500);
    l_object_type               VARCHAR2(30);
    l_object_id                 NUMBER;
    l_error_msg                 VARCHAR2(2000);

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    document_type := 'text/plain';

    -- parse document_id for the ':' dividing item type name from item key value
    l_hyphen_pos1 := INSTR (document_id, ':');
    l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
    l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

    l_object_type := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_TYPE'
    );

    l_object_id := wf_engine.getitemattrNumber
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_ID'
    );

    l_requester := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'REQUESTER'
    );

    l_requester_note := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'REQUESTER_NOTE'
    );

    OPEN get_mel_cdl_details(l_object_id);
    FETCH get_mel_cdl_details into l_mel_cdl_rec;
    IF (get_mel_cdl_details%NOTFOUND)
    THEN
        CLOSE get_mel_cdl_details;

        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_ID_INVALID');
        fnd_message.set_token('HRD_ID', l_object_id, false);
        fnd_msg_pub.add;

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.message
            (
                fnd_log.level_exception,
                l_debug_module,
                false
            );
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    ELSE
        CLOSE get_mel_cdl_details;

        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_APPROVAL');
        fnd_message.set_token('HRD_ID',l_object_id, false);
        fnd_message.set_token('PCN',l_mel_cdl_rec.name, false);
        fnd_message.set_token('REV',l_mel_cdl_rec.revision, false);
        fnd_message.set_token('TYPE',l_mel_cdl_rec.mel_cdl_type_code, false);
        fnd_message.set_token('REQUESTER',l_requester, false);
        fnd_message.set_token('NOTE',l_requester_note, false);
        l_body := fnd_message.get;

    END IF;

    document := document || l_body;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'document='||document
        );
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    RETURN;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => l_item_type,
            p_itemkey           => l_item_key,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NTF_APPROVAL',
            l_item_type,
            l_item_key,
            l_error_msg
        );
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NTF_APPROVAL',
            l_item_type,
            l_item_key
        );
        RAISE;
END NTF_APPROVAL;

PROCEDURE NTF_APPROVAL_REMINDER
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NTF_APPROVAL_REMINDER';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_hyphen_pos1               NUMBER;
    l_item_type                 VARCHAR2(30);
    l_item_key                  VARCHAR2(30);
    l_requester                 VARCHAR2(30);
    l_requester_note            VARCHAR2(4000);
    l_body                      VARCHAR2(3500);
    l_object_type               VARCHAR2(30);
    l_object_id                 NUMBER;
    l_error_msg                 VARCHAR2(2000);

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    document_type := 'text/plain';

    -- parse document_id for the ':' dividing item type name from item key value
    l_hyphen_pos1 := INSTR (document_id, ':');
    l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
    l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

    l_object_type := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_TYPE'
    );

    l_object_id := wf_engine.getitemattrNumber
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_ID'
    );

    l_requester := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'REQUESTER'
    );

    l_requester_note := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'REQUESTER_NOTE'
    );

    OPEN get_mel_cdl_details(l_object_id);
    FETCH get_mel_cdl_details into l_mel_cdl_rec;
    IF (get_mel_cdl_details%NOTFOUND)
    THEN
        CLOSE get_mel_cdl_details;

        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_ID_INVALID');
        fnd_message.set_token('HRD_ID', l_object_id, false);
        fnd_msg_pub.add;

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.message
            (
                fnd_log.level_exception,
                l_debug_module,
                false
            );
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    ELSE
        CLOSE get_mel_cdl_details;

        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_REMIND');
        fnd_message.set_token('HRD_ID',l_object_id, false);
        fnd_message.set_token('PCN',l_mel_cdl_rec.name, false);
        fnd_message.set_token('REV',l_mel_cdl_rec.revision, false);
        fnd_message.set_token('TYPE',l_mel_cdl_rec.mel_cdl_type_code, false);
        fnd_message.set_token('REQUESTER',l_requester, false);
        fnd_message.set_token('NOTE',l_requester_note, false);
        l_body := fnd_message.get;

    END IF;

    document := document || l_body;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'document='||document
        );
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    RETURN;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => l_item_type,
            p_itemkey           => l_item_key,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NTF_APPROVAL_REMINDER',
            l_item_type,
            l_item_key,
            l_error_msg
        );
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NTF_APPROVAL_REMINDER',
            l_item_type,
            l_item_key
        );
        RAISE;
END NTF_APPROVAL_REMINDER;

PROCEDURE NTF_ERROR_ACT
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NTF_ERROR_ACT';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_hyphen_pos1               NUMBER;
    l_item_type                 VARCHAR2(30);
    l_item_key                  VARCHAR2(30);
    l_body                      VARCHAR2(3500);
    l_object_type               VARCHAR2(30);
    l_object_id                 NUMBER;
    l_error_msg                 VARCHAR2(2000);

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    document_type := 'text/plain';

    -- parse document_id for the ':' dividing item type name from item key value
    l_hyphen_pos1 := INSTR (document_id, ':');
    l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
    l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

    l_object_type := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_TYPE'
    );

    l_object_id := wf_engine.getitemattrNumber
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_ID'
    );

    l_error_msg := wf_engine.getitemattrText
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'ERROR_MSG'
    );

    OPEN get_mel_cdl_details(l_object_id);
    FETCH get_mel_cdl_details into l_mel_cdl_rec;
    IF (get_mel_cdl_details%NOTFOUND)
    THEN
        CLOSE get_mel_cdl_details;

        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_ID_INVALID');
        fnd_message.set_token('HRD_ID', l_object_id, false);
        fnd_msg_pub.add;

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.message
            (
                fnd_log.level_exception,
                l_debug_module,
                false
            );
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    ELSE
        CLOSE get_mel_cdl_details;

        fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_ERROR_ACT');
        fnd_message.set_token('HRD_ID',l_object_id, false);
        fnd_message.set_token('PCN',l_mel_cdl_rec.name, false);
        fnd_message.set_token('REV',l_mel_cdl_rec.revision, false);
        fnd_message.set_token('TYPE',l_mel_cdl_rec.mel_cdl_type_code, false);
        fnd_message.set_token('ERR_MSG',l_error_msg, false);
        l_body := fnd_message.get;

    END IF;

    document := document || l_body;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'document='||document
        );
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    RETURN;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => l_item_type,
            p_itemkey           => l_item_key,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NTF_ERROR_ACT',
            l_item_type,
            l_item_key,
            l_error_msg
        );
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NTF_ERROR_ACT',
            l_item_type,
            l_item_key
        );
        RAISE;
END NTF_ERROR_ACT;

PROCEDURE UPDATE_STATUS
(
    itemtype        IN          VARCHAR2,
    itemkey         IN          VARCHAR2,
    actid           IN          NUMBER,
    funcmode        IN          VARCHAR2,
    resultout       OUT NOCOPY  VARCHAR2
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.UPDATE_STATUS';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_object_id                 NUMBER;
    l_object_ovn                NUMBER;
    l_next_status               VARCHAR2(30);
    l_error_msg                 VARCHAR2(2000);

    CURSOR get_prev_rev_details
    (
        p_pc_node_id        number,
        p_mel_cdl_type      varchar2,
        p_version_number    number
    )
    IS
    SELECT  mel_cdl_header_id,
            revision_date
    FROM    ahl_mel_cdl_headers
    WHERE   pc_node_id = p_pc_node_id AND
            mel_cdl_type_code = p_mel_cdl_type AND
            version_number = p_version_number - 1;

    l_prev_mel_cdl_header_id    NUMBER;
    l_prev_revision_date        DATE;
    l_prev_expired_date         DATE;

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN')
    THEN

        l_object_id := wf_engine.getitemattrnumber
        (
            itemtype    => itemtype,
            itemkey     => itemkey,
            aname       => 'OBJECT_ID'
        );

        l_object_ovn := wf_engine.getitemattrnumber
        (
            itemtype    => itemtype,
            itemkey     => itemkey,
            aname       => 'OBJECT_VER'
        );

        OPEN get_mel_cdl_details(l_object_id);
        FETCH get_mel_cdl_details into l_mel_cdl_rec;
        IF (get_mel_cdl_details%NOTFOUND OR l_mel_cdl_rec.object_version_number <> l_object_ovn)
        THEN
            CLOSE get_mel_cdl_details;

            fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_ID_INVALID');
            fnd_message.set_token('HRD_ID', l_object_id, false);
            fnd_msg_pub.add;

            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
            THEN
                fnd_log.message
                (
                    fnd_log.level_exception,
                    l_debug_module,
                    false
                );
            END IF;

            resultout := 'COMPLETE:ERROR';
            RAISE FND_API.G_EXC_ERROR;

        END IF;
        CLOSE get_mel_cdl_details;

        -- Priyan :
        -- Fix for Bug #5484980
        -- Changed wf_engine.GetItemAttrNumber  to wf_engine.GetItemAttrText

        l_next_status := wf_engine.GetItemAttrText
        (
            itemtype    => itemtype,
            itemkey     => itemkey,
            aname       => 'UPDATE_GEN_STATUS'
        );

        -- Complete the current revision and expire the old one...
        UPDATE  ahl_mel_cdl_headers
        SET     status_code = l_next_status,
                object_version_number = l_object_ovn + 1,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
        WHERE   mel_cdl_header_id = l_object_id;

        IF (l_mel_cdl_rec.version_number > 1)
        THEN
            -- Retrieve previous revision details
            OPEN get_prev_rev_details(l_mel_cdl_rec.pc_node_id, l_mel_cdl_rec.mel_cdl_type_code, l_mel_cdl_rec.version_number);
            FETCH get_prev_rev_details INTO l_prev_mel_cdl_header_id, l_prev_revision_date;
            CLOSE get_prev_rev_details;

            -- Calculate previous revision's expired_date
            l_prev_expired_date := l_mel_cdl_rec.revision_date - 1;
            IF (trunc(l_prev_expired_date) < trunc(l_prev_revision_date))
            THEN
                l_prev_expired_date := l_prev_revision_date;
            END IF;

            -- Once the current revision of the MEL/CDL is complete, need to expire the earlier revision
            UPDATE  ahl_mel_cdl_headers
            SET     expired_date = l_prev_expired_date,
                    object_version_number = object_version_number + 1,
                    last_update_date = sysdate,
                    last_updated_by = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
            WHERE   mel_cdl_header_id = l_prev_mel_cdl_header_id;
        END IF;

        resultout := 'COMPLETE:SUCCESS';
        RETURN;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL')
    THEN
        resultout := 'COMPLETE:';
        RETURN;
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT')
    THEN
        resultout := 'COMPLETE:';
        RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => itemtype,
            p_itemkey           => itemkey,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'UPDATE_STATUS',
            itemtype,
            itemkey,
            actid,
            funcmode,
            l_error_msg
        );
        resultout := 'COMPLETE:ERROR';
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'UPDATE_STATUS',
            itemtype,
            itemkey,
            actid,
            'Unexpected Error! '||SUBSTR(SQLERRM,1,240)
        );
        RAISE;
END UPDATE_STATUS;

PROCEDURE REVERT_STATUS
(
    itemtype        IN          VARCHAR2,
    itemkey         IN          VARCHAR2,
    actid           IN          NUMBER,
    funcmode        IN          VARCHAR2,
    resultout       OUT NOCOPY  VARCHAR2
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.REVERT_STATUS';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_object_id                 NUMBER;
    l_object_ovn                NUMBER;
    l_next_status               VARCHAR2(30);
    l_error_msg                 VARCHAR2(2000);

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN')
    THEN

        l_object_id := wf_engine.getitemattrnumber
        (
            itemtype    => itemtype,
            itemkey     => itemkey,
            aname       => 'OBJECT_ID'
        );

        l_object_ovn := wf_engine.getitemattrnumber
        (
            itemtype    => itemtype,
            itemkey     => itemkey,
            aname       => 'OBJECT_VER'
        );

        OPEN get_mel_cdl_details(l_object_id);
        FETCH get_mel_cdl_details into l_mel_cdl_rec;
        IF (get_mel_cdl_details%NOTFOUND OR l_mel_cdl_rec.object_version_number <> l_object_ovn)
        THEN
            CLOSE get_mel_cdl_details;

            fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_ID_INVALID');
            fnd_message.set_token('HRD_ID', l_object_id, false);
            fnd_msg_pub.add;

            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
            THEN
                fnd_log.message
                (
                    fnd_log.level_exception,
                    l_debug_module,
                    false
                );
            END IF;

            resultout := 'COMPLETE:ERROR';
            RAISE FND_API.G_EXC_ERROR;

        END IF;
        CLOSE get_mel_cdl_details;

        l_next_status := wf_engine.getitemattrnumber
        (
            itemtype    => itemtype,
            itemkey     => itemkey,
            aname       => 'ORG_STATUS_ID'
        );

        UPDATE  ahl_mel_cdl_headers
        SET     status_code = l_next_status,
                object_version_number = l_object_ovn + 1,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
        WHERE   mel_cdl_header_id = l_object_id;

        resultout := 'COMPLETE:SUCCESS';
        RETURN;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL')
    THEN
        resultout := 'COMPLETE:';
        RETURN;
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT')
    THEN
        resultout := 'COMPLETE:';
        RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => itemtype,
            p_itemkey           => itemkey,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'REVERT_STATUS',
            itemtype,
            itemkey,
            actid,
            funcmode,
            l_error_msg
        );
        resultout := 'COMPLETE:ERROR';
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'REVERT_STATUS',
            itemtype,
            itemkey,
            actid,
            'Unexpected Error! '||SUBSTR(SQLERRM,1,240)
        );
        RAISE;
END REVERT_STATUS;


-- Procedures used by Non-Routine MEL/CDl approval --
-----------------------------------------------------


--  Start of Comments  --
--
--  Procedure name      : NR_SET_ACTIVITY_DETAILS
--  Type                : Private
--  Description         : This procedure sets all item attribute details for the NR approval rule
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_SET_ACTIVITY_DETAILS
(
    itemtype        IN          VARCHAR2,
    itemkey         IN          VARCHAR2,
    actid           IN          NUMBER,
    funcmode        IN          VARCHAR2,
    resultout       OUT NOCOPY  VARCHAR2
)

IS

    -- Declare cursors
    CURSOR get_nr_details_csr(p_deferral_id IN NUMBER) IS
      select cs.incident_number incident_number, cit.name name, udf.object_version_number,
           mtl.concatenated_segments item, csi.serial_number, ue.mel_cdl_type_code,
           cs.expected_resolution_date, seq.ata_code, arc.repair_time,
           apn.name node_name, aph.name class_name, cs.summary, ciu.name repair_category,
           (select visit_number from ahl_visit_tasks_b tsk, ahl_visits_b vst where
            vst.visit_id = tsk.visit_id and tsk.unit_effectivity_id =
            ue.unit_effectivity_id and rownum < 2) visit_number
      from cs_incidents_all_vl cs, cs_incident_types_vl cit,
           ahl_unit_effectivities_b ue, ahl_unit_deferrals_b udf,
           csi_item_instances csi, mtl_system_items_kfv mtl,
           ahl_mel_cdl_ata_sequences seq, ahl_repair_categories arc,
           ahl_mel_cdl_headers mch, ahl_pc_headers_b aph, ahl_pc_nodes_b apn,
           cs_incident_urgencies_vl ciu
      where udf.unit_effectivity_id = ue.unit_effectivity_id
        and ue.cs_incident_id = cs.incident_id
        and cs.incident_type_id = cit.incident_type_id
        and ue.csi_item_instance_id = csi.instance_id
        and mtl.inventory_item_id = csi.inventory_item_id
        and mtl.organization_id = csi.inv_master_organization_id
        and udf.ata_sequence_id = seq.MEL_CDL_ATA_SEQUENCE_ID
        and seq.repair_category_id = arc.repair_category_id
        and mch.mel_cdl_header_id = seq.mel_cdl_header_id
        and mch.pc_node_id = apn.pc_node_id
        and apn.pc_header_id = aph.pc_header_id
        and arc.sr_urgency_id = ciu.INCIDENT_URGENCY_ID
        and udf.unit_deferral_id = p_deferral_id;

    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NR_SET_ACTIVITY_DETAILS';
    l_debug_stmt    CONSTANT    NUMBER          := fnd_log.level_statement;
    l_debug_proc    CONSTANT    NUMBER          := fnd_log.level_procedure;
    l_debug_runtime CONSTANT    NUMBER          := fnd_log.g_current_runtime_level;
    l_debug_exception CONSTANT  NUMBER          := fnd_log.level_exception;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_object_id                 NUMBER;
    l_object_ovn                NUMBER;
    l_object_details            AHL_GENERIC_APRV_PVT.OBJRECTYP;
    l_approval_rule_id          NUMBER;
    l_approver_seq              NUMBER;
    l_subject                   VARCHAR2(500);
    l_error_msg                 VARCHAR2(2000);

    l_nr_rec                    get_nr_details_csr%ROWTYPE;
    l_requester_note            VARCHAR2(4000);
    l_temp_subject              VARCHAR2(4000);

BEGIN

    FND_MSG_PUB.INITIALIZE;

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (l_debug_proc >= l_debug_runtime)
    THEN
        fnd_log.string
        (
            l_debug_proc,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    l_object_id := wf_engine.getitemattrnumber
    (
        itemtype    => itemtype,
        itemkey     => itemkey,
        aname       => 'OBJECT_ID'
    );

    l_object_ovn := wf_engine.getitemattrnumber
    (
        itemtype    => itemtype,
        itemkey     => itemkey,
        aname       => 'OBJECT_VER'
    );

    IF (l_debug_stmt >= l_debug_runtime)
    THEN
        fnd_log.string
        (
            l_debug_stmt,
            l_debug_module,
            'OBJECT_ID='||l_object_id||' OBJECT_VER='||l_object_ovn
        );
    END IF;

    l_object_details.operating_unit_id := NULL;
    l_object_details.priority := NULL;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN')
    THEN

        OPEN get_nr_details_csr(l_object_id);
        FETCH get_nr_details_csr into l_nr_rec;
        IF (get_nr_details_csr%NOTFOUND OR l_nr_rec.object_version_number <> l_object_ovn)
        THEN
            CLOSE get_nr_details_csr;

            fnd_message.set_name('AHL', 'AHL_UMP_NR_NTF_ID_INVALID');
            fnd_message.set_token('HDR_ID', l_object_id, false);
            fnd_msg_pub.add;

            IF (l_debug_exception >= l_debug_runtime)
            THEN
                fnd_log.message
                (
                    l_debug_exception,
                    l_debug_module,
                    false
                );
            END IF;

            resultout := 'COMPLETE:ERROR';
            RAISE FND_API.G_EXC_ERROR;

        END IF;
        CLOSE get_nr_details_csr;

        fnd_message.set_name('AHL','AHL_UMP_NR_APPR_SUBJECT');
        fnd_message.set_token('MEL_CDL', l_nr_rec.mel_cdl_type_code);
        fnd_message.set_token('NR_NUM', l_nr_rec.incident_number);
        fnd_message.set_token('VISIT_NUM', l_nr_rec.visit_number);
        l_temp_subject := fnd_message.get;

        -- form requester note.
        fnd_message.set_name('AHL','AHL_UMP_NR_REQ_NOTE');
        fnd_message.set_token('INCIDENT_NUMBER', l_nr_rec.incident_number);
        fnd_message.set_token('VISIT_NUMBER',l_nr_rec.visit_number);
        fnd_message.set_token('SUMMARY', l_nr_rec.summary);
        fnd_message.set_token('TYPE_NAME',l_nr_rec.name);
        fnd_message.set_token('ITEM',l_nr_rec.Item);
        fnd_message.set_token('SERIAL',l_nr_rec.serial_number);
        l_requester_note := fnd_message.get;

        fnd_message.set_name('AHL','AHL_UMP_MEL_CDL_REQ_NOTE');
        fnd_message.set_token('MEL_CDL', l_nr_rec.mel_cdl_type_code);
        fnd_message.set_token('ATA_CODE', l_nr_rec.ata_code);
        fnd_message.set_token('PROD_CLASS', l_nr_rec.class_name);
        fnd_message.set_token('PROD_CLASS_NODE', l_nr_rec.node_name);
        fnd_message.set_token('REP_CAT', l_nr_rec.repair_category);
        fnd_message.set_token('REP_TIME', l_nr_rec.repair_time);
        fnd_message.set_token('EXP_DATE', to_char(l_nr_rec.expected_resolution_date,
                               fnd_date.outputDT_mask));

        l_requester_note := l_requester_note || fnd_message.get;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                   fnd_log.string
                   (
                       l_debug_stmt,
                       l_debug_module,
                       'SUBJECT : ' || l_temp_subject
                   );
           fnd_log.string
                   (
                       l_debug_stmt,
                       l_debug_module,
                       'REQUESTER NOTE : ' || l_requester_note
                   );
        END IF;

        /* REQUESTER_NOTE */
        wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'REQUESTER_NOTE'
                 ,avalue   => l_requester_note
        );

        /* FORWARD_SUBJECT */
        fnd_message.set_name('AHL', 'AHL_UMP_NR_NTF_FORWARD_SUBJ');
        l_subject := fnd_message.get || l_temp_subject;

        wf_engine.setitemattrtext
        (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'FORWARD_SUBJECT',
            avalue   => l_subject
        );

        IF (l_debug_stmt >= l_debug_runtime)
        THEN
            fnd_log.string
            (
                l_debug_stmt,
                l_debug_module,
                'FORWARD_SUBJECT='||l_subject
            );
        END IF;

        /* APPROVAL_SUBJECT */
        fnd_message.set_name('AHL', 'AHL_UMP_NR_NTF_APPROVAL_SUBJ');
        l_subject := fnd_message.get || l_temp_subject;

        wf_engine.setitemattrtext
        (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'APPROVAL_SUBJECT',
            avalue   => l_subject
        );

        IF (l_debug_stmt >= l_debug_runtime)
        THEN
            fnd_log.string
            (
                l_debug_stmt,
                l_debug_module,
                'APPROVAL_SUBJECT='||l_subject
            );
        END IF;

        /* REJECT_SUBJECT */
        fnd_message.set_name('AHL', 'AHL_UMP_NR_NTF_REJECT_SUBJ');
        l_subject := fnd_message.get || l_temp_subject;

        wf_engine.setitemattrtext
        (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'REJECT_SUBJECT',
            avalue   => l_subject
        );

        IF (l_debug_stmt >= l_debug_runtime)
        THEN
            fnd_log.string
            (
                l_debug_stmt,
                l_debug_module,
                'REJECT_SUBJECT='||l_subject
            );
        END IF;

        /* APPROVED_SUBJECT */
        fnd_message.set_name('AHL', 'AHL_UMP_NR_NTF_APPROVED_SUBJ');
        l_subject := fnd_message.get || l_temp_subject;

        wf_engine.setitemattrtext
        (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'APPROVED_SUBJECT',
            avalue   => l_subject
        );

        IF (l_debug_stmt >= l_debug_runtime)
        THEN
            fnd_log.string
            (
                l_debug_stmt,
                l_debug_module,
                'APPROVED_SUBJECT='||l_subject
            );
        END IF;

        /* FINAL_SUBJECT */
        fnd_message.set_name('AHL', 'AHL_UMP_NR_NTF_FINAL_SUBJ');
        l_subject := fnd_message.get || l_temp_subject;

        wf_engine.setitemattrtext
        (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'FINAL_SUBJECT',
            avalue   => l_subject
        );

        IF (l_debug_stmt >= l_debug_runtime)
        THEN
            fnd_log.string
            (
                l_debug_stmt,
                l_debug_module,
                'FINAL_SUBJECT='||l_subject
            );
        END IF;

        /* REMIND_SUBJECT */
        fnd_message.set_name('AHL', 'AHL_UMP_NR_NTF_REMIND_SUBJ');
        l_subject := fnd_message.get || l_temp_subject;

        wf_engine.setitemattrtext
        (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'REMIND_SUBJECT',
            avalue   => l_subject
        );

        IF (l_debug_stmt >= l_debug_runtime)
        THEN
            fnd_log.string
            (
                l_debug_stmt,
                l_debug_module,
                'REMIND_SUBJECT='||l_subject
            );
        END IF;

        /* ERROR_SUBJECT */
        fnd_message.set_name('AHL', 'AHL_UMP_NR_NTF_ERROR_SUBJ');
        l_subject := fnd_message.get || l_temp_subject;

        wf_engine.setitemattrtext
        (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'ERROR_SUBJECT',
            avalue   => l_subject
        );

        IF (l_debug_stmt >= l_debug_runtime)
        THEN
            fnd_log.string
            (
                l_debug_stmt,
                l_debug_module,
                'ERROR_SUBJECT='||l_subject
            );
        END IF;

        /* Getting approver details */
        AHL_GENERIC_APRV_PVT.GET_APPROVAL_DETAILS
        (
            p_object            => G_NR_APPR_OBJ,
            p_approval_type     => G_APPR_TYPE,
            p_object_details    => l_object_details,
            x_approval_rule_id  => l_approval_rule_id,
            x_approver_seq      => l_approver_seq,
            x_return_status     => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_SUCCESS
        THEN
            wf_engine.setitemattrnumber
            (
                itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'RULE_ID',
                avalue   => l_approval_rule_id
            );

            IF (l_debug_stmt >= l_debug_runtime)
            THEN
                fnd_log.string
                (
                    fnd_log.level_statement,
                    l_debug_module,
                    'RULE_ID='||l_approval_rule_id
                );
            END IF;

            wf_engine.setitemattrnumber
            (
                itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'APPROVER_SEQ',
                avalue   => l_approver_seq
            );

            IF (l_debug_stmt >= l_debug_runtime)
            THEN
                fnd_log.string
                (
                    fnd_log.level_statement,
                    l_debug_module,
                    'APPROVER_SEQ='||l_approver_seq
                );
            END IF;

            resultout := 'COMPLETE:SUCCESS';
        ELSE
            resultout := 'COMPLETE:ERROR';
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL')
    THEN
        resultout := 'COMPLETE:';
        RETURN;
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT')
    THEN
        resultout := 'COMPLETE:';
        RETURN;
    END IF;

    IF (l_debug_proc >= l_debug_runtime)
    THEN
        fnd_log.string
        (
            l_debug_proc,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => itemtype,
            p_itemkey           => itemkey,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (l_debug_exception >= l_debug_runtime)
        THEN
            fnd_log.string
            (
                l_debug_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_SET_ACTIVITY_DETAILS',
            itemtype,
            itemkey,
            actid,
            funcmode,
            l_error_msg
        );
        resultout := 'COMPLETE:ERROR';
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_SET_ACTIVITY_DETAILS',
            itemtype,
            itemkey,
            actid,
            'Unexpected Error! '||SUBSTR(SQLERRM,1,240)
        );
        RAISE;

END NR_SET_ACTIVITY_DETAILS;

--  Start of Comments  --
--
--  Procedure name      : NR_NTF_FORWARD_FYI
--  Type                : Private
--  Description         : This procedure generates the FYI document for forwarded workflow notifications
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_NTF_FORWARD_FYI
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
) IS

    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NR_NTF_FORWARD_FYI';

    l_debug_stmt    CONSTANT    NUMBER          := fnd_log.level_statement;
    l_debug_proc    CONSTANT    NUMBER          := fnd_log.level_procedure;
    l_debug_runtime CONSTANT    NUMBER          := fnd_log.g_current_runtime_level;
    l_debug_exception CONSTANT  NUMBER          := fnd_log.level_exception;


    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_hyphen_pos1               NUMBER;
    l_item_type                 VARCHAR2(30);
    l_item_key                  VARCHAR2(30);
    l_approver                  VARCHAR2(30);
    l_body                      VARCHAR2(3500);
    l_object_type               VARCHAR2(30);
    l_object_id                 NUMBER;
    l_error_msg                 VARCHAR2(2000);
    l_requester_note            VARCHAR2(4000);

BEGIN

    IF (l_debug_proc >= l_debug_runtime)
    THEN
        fnd_log.string
        (
            l_debug_proc,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    document_type := 'text/plain';

    -- parse document_id for the ':' dividing item type name from item key value
    l_hyphen_pos1 := INSTR (document_id, ':');
    l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
    l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

    l_object_type := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_TYPE'
    );

    l_object_id := wf_engine.getitemattrNumber
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_ID'
    );

    l_approver := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'APPROVER'
    );

    l_requester_note := wf_engine.getitemattrtext
    (
        itemtype => l_item_type
        ,itemkey  => l_item_key
        ,aname    => 'REQUESTER_NOTE'
    );

    fnd_message.set_name('AHL', 'AHL_UMP_NR_NTF_FYI_FWD');
    fnd_message.set_token('APPROVER',l_approver, false);
    l_body := fnd_message.get;

    document := l_body || l_requester_note;

    IF (l_debug_stmt >= l_debug_runtime)
    THEN
        fnd_log.string
        (
            l_debug_stmt,
            l_debug_module,
            'document='||document
        );
    END IF;

    IF (l_debug_proc >= l_debug_runtime)
    THEN
        fnd_log.string
        (
            l_debug_proc,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    RETURN;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => l_item_type,
            p_itemkey           => l_item_key,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (l_debug_exception >= l_debug_runtime)
        THEN
            fnd_log.string
            (
                l_debug_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_NTF_FORWARD_FYI',
            l_item_type,
            l_item_key,
            l_error_msg
        );
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_NTF_FORWARD_FYI',
            l_item_type,
            l_item_key
        );
        RAISE;
END NR_NTF_FORWARD_FYI;


--  Start of Comments  --
--
--  Procedure name      : NR_NTF_APPROVED_FYI
--  Type                : Private
--  Description         : This procedure generates the FYI document for approved workflow notifications
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_NTF_APPROVED_FYI
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
) IS

    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NR_NTF_APPROVED_FYI';

    l_debug_stmt    CONSTANT    NUMBER          := fnd_log.level_statement;
    l_debug_proc    CONSTANT    NUMBER          := fnd_log.level_procedure;
    l_debug_runtime CONSTANT    NUMBER          := fnd_log.g_current_runtime_level;
    l_debug_exception CONSTANT  NUMBER          := fnd_log.level_exception;


    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_hyphen_pos1               NUMBER;
    l_item_type                 VARCHAR2(30);
    l_item_key                  VARCHAR2(30);
    l_approver                  VARCHAR2(30);
    l_body                      VARCHAR2(3500);
    l_object_type               VARCHAR2(30);
    l_object_id                 NUMBER;
    l_error_msg                 VARCHAR2(2000);
    l_requester_note            VARCHAR2(4000);

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    document_type := 'text/plain';

    -- parse document_id for the ':' dividing item type name from item key value
    l_hyphen_pos1 := INSTR (document_id, ':');
    l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
    l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

    l_object_type := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_TYPE'
    );

    l_object_id := wf_engine.getitemattrNumber
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_ID'
    );

    l_approver := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'APPROVER'
    );

    l_requester_note := wf_engine.getitemattrtext
    (
        itemtype => l_item_type
        ,itemkey  => l_item_key
        ,aname    => 'REQUESTER_NOTE'
    );

    fnd_message.set_name('AHL', 'AHL_UMP_NR_NTF_FYI_APPRVD');
    fnd_message.set_token('APPROVER',l_approver, false);
    l_body := fnd_message.get;

    document := document || l_body || l_requester_note;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'document='||document
        );
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => l_item_type,
            p_itemkey           => l_item_key,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_NTF_APPROVED_FYI',
            l_item_type,
            l_item_key,
            l_error_msg
        );
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_NTF_APPROVED_FYI',
            l_item_type,
            l_item_key
        );
        RAISE;
END NR_NTF_APPROVED_FYI;



--  Start of Comments  --
--
--  Procedure name      : NR_NTF_FINAL_APPROVAL_FYI
--  Type                : Private
--  Description         : This procedure generates the FYI document for final approval workflow notifications
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_NTF_FINAL_APPROVAL_FYI
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NR_NTF_FINAL_APPROVAL_FYI';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_hyphen_pos1               NUMBER;
    l_item_type                 VARCHAR2(30);
    l_item_key                  VARCHAR2(30);
    l_body                      VARCHAR2(3500);
    l_object_type               VARCHAR2(30);
    l_object_id                 NUMBER;
    l_error_msg                 VARCHAR2(2000);
    l_requester_note            VARCHAR2(4000);

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    document_type := 'text/plain';

    -- parse document_id for the ':' dividing item type name from item key value
    l_hyphen_pos1 := INSTR (document_id, ':');
    l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
    l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

    l_object_type := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_TYPE'
    );

    l_object_id := wf_engine.getitemattrNumber
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_ID'
    );

    l_requester_note := wf_engine.getitemattrtext
    (
        itemtype => l_item_type
        ,itemkey  => l_item_key
        ,aname    => 'REQUESTER_NOTE'
    );

    fnd_message.set_name('AHL', 'AHL_UMP_NR_NTF_FYI_FINAL');
    l_body := fnd_message.get;

    document := l_body || l_requester_note;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'document='||document
        );
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    RETURN;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => l_item_type,
            p_itemkey           => l_item_key,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_NTF_FINAL_APPROVAL_FYI',
            l_item_type,
            l_item_key,
            l_error_msg
        );
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_NTF_FINAL_APPROVAL_FYI',
            l_item_type,
            l_item_key
        );
        RAISE;

END NR_NTF_FINAL_APPROVAL_FYI;


--  Start of Comments  --
--
--  Procedure name      : NR_NTF_REJECTED_FYI
--  Type                : Private
--  Description         : This procedure generates the FYI document for rejected workflow notifications
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --

PROCEDURE NR_NTF_REJECTED_FYI
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NR_NTF_REJECTED_FYI';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_hyphen_pos1               NUMBER;
    l_item_type                 VARCHAR2(30);
    l_item_key                  VARCHAR2(30);
    l_approver                  VARCHAR2(30);
    l_body                      VARCHAR2(3500);
    l_object_type               VARCHAR2(30);
    l_object_id                 NUMBER;
    l_error_msg                 VARCHAR2(2000);
    l_requester_note            VARCHAR2(4000);
    l_approver_note             VARCHAR2(4000);

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    document_type := 'text/plain';

    -- parse document_id for the ':' dividing item type name from item key value
    l_hyphen_pos1 := INSTR (document_id, ':');
    l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
    l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

    l_object_type := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_TYPE'
    );

    l_object_id := wf_engine.getitemattrNumber
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_ID'
    );

    l_approver := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'APPROVER'
    );

    l_requester_note := wf_engine.getitemattrtext
    (
        itemtype => l_item_type
        ,itemkey  => l_item_key
        ,aname    => 'REQUESTER_NOTE'
    );


    l_approver_note  := wf_engine.getitemattrtext(
                                     itemtype => l_item_type,
                                     itemkey => l_item_key,
                                     aname => 'APPROVER NOTE'
                        );

    fnd_message.set_name('AHL', 'AHL_UMP_NR_NTF_FYI_RJCT');
    fnd_message.set_token('APPROVER',l_approver, false);
    l_body := fnd_message.get;

    document := l_body || l_requester_note;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'document='||document
        );
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => l_item_type,
            p_itemkey           => l_item_key,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_NTF_REJECTED_FYI',
            l_item_type,
            l_item_key,
            l_error_msg
        );
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_NTF_REJECTED_FYI',
            l_item_type,
            l_item_key
        );
        RAISE;

END NR_NTF_REJECTED_FYI;



--  Start of Comments  --
--
--  Procedure name      : NR_NTF_APPROVAL
--  Type                : Private
--  Description         : This procedure generates the document for sending to-approve notifications
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_NTF_APPROVAL
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NR_NTF_APPROVAL';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_hyphen_pos1               NUMBER;
    l_item_type                 VARCHAR2(30);
    l_item_key                  VARCHAR2(30);
    l_requester                 VARCHAR2(30);
    l_requester_note            VARCHAR2(4000);
    l_body                      VARCHAR2(3500);
    l_object_type               VARCHAR2(30);
    l_object_id                 NUMBER;
    l_error_msg                 VARCHAR2(2000);

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    document_type := 'text/plain';

    -- parse document_id for the ':' dividing item type name from item key value
    l_hyphen_pos1 := INSTR (document_id, ':');
    l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
    l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

    l_object_type := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_TYPE'
    );

    l_object_id := wf_engine.getitemattrNumber
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_ID'
    );

    l_requester := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'REQUESTER'
    );

    l_requester_note := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'REQUESTER_NOTE'
    );

    OPEN get_ue_mel_cdl_details(l_object_id);
    FETCH get_ue_mel_cdl_details INTO l_ue_mel_cdl_details_rec;
    CLOSE get_ue_mel_cdl_details;

    fnd_message.set_name('AHL', 'AHL_UMP_NR_NTF_APPROVAL');
    fnd_message.set_token('REQUESTER',l_requester, false);
    fnd_message.set_token('MEL_CDL',l_ue_mel_cdl_details_rec.mel_cdl_type_code);

    l_body := fnd_message.get;

    document := l_body || l_requester_note;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'document='||document
        );
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => l_item_type,
            p_itemkey           => l_item_key,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_NTF_APPROVAL',
            l_item_type,
            l_item_key,
            l_error_msg
        );
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_NTF_APPROVAL',
            l_item_type,
            l_item_key
        );
        RAISE;

END NR_NTF_APPROVAL;


--  Start of Comments  --
--
--  Procedure name      : NR_NTF_APPROVAL_REMINDER
--  Type                : Private
--  Description         : This procedure generates the document for sending reminders
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_NTF_APPROVAL_REMINDER
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NR_NTF_APPROVAL_REMINDER';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_hyphen_pos1               NUMBER;
    l_item_type                 VARCHAR2(30);
    l_item_key                  VARCHAR2(30);
    l_requester                 VARCHAR2(30);
    l_requester_note            VARCHAR2(4000);
    l_body                      VARCHAR2(3500);
    l_object_type               VARCHAR2(30);
    l_object_id                 NUMBER;
    l_error_msg                 VARCHAR2(2000);

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    document_type := 'text/plain';

    -- parse document_id for the ':' dividing item type name from item key value
    l_hyphen_pos1 := INSTR (document_id, ':');
    l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
    l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

    l_object_type := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_TYPE'
    );

    l_object_id := wf_engine.getitemattrNumber
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_ID'
    );

    l_requester := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'REQUESTER'
    );

    l_requester_note := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'REQUESTER_NOTE'
    );

    OPEN get_ue_mel_cdl_details(l_object_id);
    FETCH get_ue_mel_cdl_details into l_ue_mel_cdl_details_rec;
    IF (get_ue_mel_cdl_details%NOTFOUND)
    THEN
       CLOSE get_ue_mel_cdl_details;
       fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_ID_INVALID');
       fnd_message.set_token('HDR_ID', l_object_id, false);
       fnd_msg_pub.add;
       IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
       THEN
           fnd_log.message
           (
               fnd_log.level_exception,
               l_debug_module,
               false
           );
       END IF;
       RAISE FND_API.G_EXC_ERROR;

   END IF;
   CLOSE get_ue_mel_cdl_details;

   fnd_message.set_name('AHL', 'AHL_UMP_NR_NTF_REMIND');
   fnd_message.set_token('REQUESTER',l_requester, false);
   fnd_message.set_token('MEL_CDL',l_ue_mel_cdl_details_rec.mel_cdl_type_code, false);
   l_body := fnd_message.get;

   document := l_body || l_requester_note;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
   THEN
       fnd_log.string
       (
           fnd_log.level_statement,
           l_debug_module,
           'document='||document
        );
   END IF;

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
   THEN
        fnd_log.string
       (
           fnd_log.level_procedure,
           l_debug_module||'.end',
           'At the end of PLSQL procedure'
       );
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => l_item_type,
            p_itemkey           => l_item_key,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_NTF_APPROVAL_REMINDER',
            l_item_type,
            l_item_key,
            l_error_msg
        );
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_NTF_APPROVAL_REMINDER',
            l_item_type,
            l_item_key
        );
        RAISE;

END NR_NTF_APPROVAL_REMINDER;



--  Start of Comments  --
--
--  Procedure name      : NR_NTF_ERROR_ACT
--  Type                : Private
--  Description         : This procedure generates the document for requesting action on error
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_NTF_ERROR_ACT
(
    document_id     IN              VARCHAR2,
    display_type    IN              VARCHAR2,
    document        IN OUT NOCOPY   VARCHAR2,
    document_type   IN OUT NOCOPY   VARCHAR2
)

IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NR_NTF_ERROR_ACT';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_hyphen_pos1               NUMBER;
    l_item_type                 VARCHAR2(30);
    l_item_key                  VARCHAR2(30);
    l_body                      VARCHAR2(3500);
    l_object_type               VARCHAR2(30);
    l_object_id                 NUMBER;
    l_error_msg                 VARCHAR2(2000);
    l_requester_note            VARCHAR2(4000);

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    document_type := 'text/plain';

    -- parse document_id for the ':' dividing item type name from item key value
    l_hyphen_pos1 := INSTR (document_id, ':');
    l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
    l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

    l_object_type := wf_engine.getitemattrtext
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_TYPE'
    );

    l_object_id := wf_engine.getitemattrNumber
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'OBJECT_ID'
    );

    l_error_msg := wf_engine.getitemattrText
    (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname    => 'ERROR_MSG'
    );

    l_requester_note := wf_engine.getitemattrtext(
                 itemtype => l_item_type
                 ,itemkey  => l_item_key
                 ,aname    => 'REQUESTER_NOTE'
    );

    fnd_message.set_name('AHL', 'AHL_UMP_NR_NTF_ERROR_ACT');
    fnd_message.set_token('ERR_MSG',l_error_msg, false);
    l_body := fnd_message.get;

    document := l_body || l_requester_note;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'document='||document
        );
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    RETURN;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => l_item_type,
            p_itemkey           => l_item_key,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_NTF_ERROR_ACT',
            l_item_type,
            l_item_key,
            l_error_msg
        );
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_NTF_ERROR_ACT',
            l_item_type,
            l_item_key
        );
        RAISE;

END NR_NTF_ERROR_ACT;


--  Start of Comments  --
--
--  Procedure name      : NR_UPDATE_STATUS
--  Type                : Private
--  Description         : This procedure handles the final complete step of the workflow process
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_UPDATE_STATUS
(
    itemtype        IN          VARCHAR2,
    itemkey         IN          VARCHAR2,
    actid           IN          NUMBER,
    funcmode        IN          VARCHAR2,
    resultout       OUT NOCOPY  VARCHAR2
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NR_UPDATE_STATUS';

    l_error_msg                VARCHAR2(4000);
    l_approval_status          VARCHAR2(30);
    l_new_status               VARCHAR2(30);
    l_object_id                NUMBER;
    l_object_version_number    NUMBER;
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(4000);
    l_return_status            VARCHAR2(1);
    l_approver_note            VARCHAR2(4000);

    -- get deferral details.
    cursor ue_deferral_csr(p_unit_deferral_id  IN NUMBER)
    is
        select  unit_effectivity_id, object_version_number, unit_deferral_type,
                approval_status_code, ata_sequence_id
        from    ahl_unit_deferrals_b
        where   unit_deferral_id = p_unit_deferral_id and
                unit_deferral_type in ('MEL', 'CDL')
        for update of object_version_number;

    -- get ue details.
    cursor unit_effect_csr (p_ue_id IN NUMBER)
    is
       select   unit_effectivity_id, status_code,
                cs_incident_id, MEL_CDL_TYPE_CODE, csi_item_instance_id,
                unit_config_header_id
       from     ahl_unit_effectivities_b
       where    unit_effectivity_id = p_ue_id
         and    object_type = 'SR'
         and    (status_code IS NULL or status_code = 'INIT_DUE')
       for update of object_version_number;

    l_deferral_rec   ue_deferral_csr%ROWTYPE;
    l_ue_rec         unit_effect_csr%ROWTYPE;

BEGIN
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			l_debug_module || '.begin',
			'At the start of PLSQL procedure'
		);
  END IF;

  SAVEPOINT AHL_NR_UPDATE_STATUS;

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- MOAC initialization.
  MO_GLOBAL.init('AHL');

  IF (funcmode = 'RUN') THEN

     l_approval_status := wf_engine.getitemattrtext(
                           itemtype => itemtype,
                           itemkey  => itemkey,
                           aname    => 'UPDATE_GEN_STATUS'
                        );

     l_object_id   := wf_engine.getitemattrnumber(
                                     itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'OBJECT_ID'
                                 );
     l_object_version_number := wf_engine.getitemattrnumber(
                                     itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'OBJECT_VER'
                                 );
     l_approver_note         := wf_engine.getitemattrtext(
                                     itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'APPROVER NOTE'
                                 );

     UPDATE AHL_UNIT_DEFERRALS_TL
     SET approver_notes = l_approver_note,
     SOURCE_LANG = userenv('LANG')
     WHERE unit_deferral_id = l_object_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			l_debug_module,
			'unit_deferral_id : ' || l_object_id
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			l_debug_module,
			'object_version_number : ' || l_object_version_number
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			l_debug_module,
			'approval status : ' || l_approval_status
		);

     END IF;

     IF (l_approval_status IN( 'DEFERRED')) THEN

        l_new_status := wf_engine.getitemattrText(
                               itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'NEW_STATUS_ID'
                            );

        -- get deferral details.
        OPEN ue_deferral_csr(l_object_id);
        FETCH ue_deferral_csr INTO l_deferral_rec;
        IF (ue_deferral_csr%NOTFOUND) THEN
          CLOSE ue_deferral_csr;
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_NR_NTF_ID_INVALID');
          FND_MESSAGE.Set_Token('HDR_ID',l_object_id);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE ue_deferral_csr;

        -- check deferral ovn.

        -- get ue details.
        OPEN unit_effect_csr(l_deferral_rec.unit_effectivity_id);
        FETCH unit_effect_csr INTO l_ue_rec;
        IF (unit_effect_csr%NOTFOUND) THEN
          CLOSE unit_effect_csr;
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_NR_WF_UE_INVALID');
          FND_MESSAGE.Set_Token('UE_ID',l_deferral_rec.unit_effectivity_id);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE unit_effect_csr;

        -- Check ue status.

        -- Check Unit locked.
        IF AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => null,
                                           p_ue_id        => l_deferral_rec.unit_effectivity_id,
                                           p_visit_id     => null,
                                           p_item_instance_id  => null) = FND_API.g_true THEN
           -- Unit is locked, therefore cannot proceed for approval.
           -- and cannot login to the workorder
           FND_MESSAGE.set_name('AHL', 'AHL_UMP_NR_UNITLCKED');
           FND_MESSAGE.set_token('UE_ID', l_deferral_rec.unit_effectivity_id);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;


        -- process for M and O procedures.
        AHL_UMP_NONROUTINES_PVT.Process_MO_procedures (l_deferral_rec.unit_effectivity_id,
                                                       l_object_id,
                                                       l_object_version_number,
                                                       l_deferral_rec.ata_sequence_id,
                                                       l_ue_rec.cs_incident_id,
                                                       l_ue_rec.csi_item_instance_id);
     ELSE
        l_new_status := wf_engine.getitemattrText(
                               itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'REJECT_STATUS_ID'
                            );
        AHL_PRD_DF_PVT.process_approval_rejected(
                    p_unit_deferral_id      => l_object_id,
                    p_object_version_number => l_object_version_number,
                    p_new_status            => l_new_status,
                    x_return_status         => l_return_status
                    );
     END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			l_debug_module,
			'new status : ' || l_new_status
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			l_debug_module,
			'return status after process_approval_rejected API call : ' || l_return_status
		);
     END IF;

     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSE
       COMMIT WORK;
     END IF;
     resultout := 'COMPLETE:';
  ELSIF (funcmode IN ('CANCEL','TIMEOUT'))THEN
     resultout := 'COMPLETE:';
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
                        fnd_log.level_procedure,
                        l_debug_module,

			'At the end of PLSQL procedure'
		);
  END IF;


EXCEPTION
  WHEN fnd_api.G_EXC_ERROR OR FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO AHL_NR_UPDATE_STATUS;

       FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
       );

       ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => itemtype,
           p_itemkey           => itemkey ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
       )               ;

      wf_core.context('AHL_MEL_CDL_APPROVALS_PVT',
                      'NR_UPDATE_STATUS',
                      itemtype,itemkey,l_error_msg);


      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string
                (
                        fnd_log.level_statement,
                        l_debug_module,
                        'Processing Exception'
                );
      END IF;

      -- update validation errors.
      UPDATE AHL_UNIT_DEFERRALS_TL
      SET approver_notes = substrb(l_error_msg,1,4000)
      WHERE unit_deferral_id = l_object_id
        AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

      UPDATE AHL_UNIT_DEFERRALS_B
      SET approval_status_code = 'DEFERRAL_REJECTED',
          object_version_number = object_version_number + 1,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
      WHERE unit_deferral_id = l_object_id;

      COMMIT WORK;

      /*
      -- process for deferral rejected status.
      NR_Rollback_Status (p_unit_deferral_id  => l_object_id,
                          p_unit_deferral_ovn => l_object_version_number,
                          p_new_status        => G_DEFERRAL_REJECTED,
                          p_itemtype          => itemtype,
                          p_itemkey           => itemkey,
                          p_actid             => actid,
                          p_funcmode          => funcmode,
                          x_resultout         => resultout);
      */
  WHEN OTHERS THEN
      ROLLBACK TO AHL_NR_UPDATE_STATUS;
      wf_core.context( 'AHL_MEL_CDL_APPROVALS_PVT', 'NR_UPDATE_STATUS', itemtype, itemkey );
      RAISE;


END NR_UPDATE_STATUS;


--  Start of Comments  --
--
--  Procedure name      : NR_REVERT_STATUS
--  Type                : Private
--  Description         : This procedure handles revert of the workflow process on any error
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE NR_REVERT_STATUS
(
    itemtype        IN          VARCHAR2,
    itemkey         IN          VARCHAR2,
    actid           IN          NUMBER,
    funcmode        IN          VARCHAR2,
    resultout       OUT NOCOPY  VARCHAR2
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.REVERT_STATUS';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_object_id                 NUMBER;
    l_object_ovn                NUMBER;
    l_orig_status               VARCHAR2(30);
    l_error_msg                 VARCHAR2(2000);

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN')
    THEN

        l_object_id := wf_engine.getitemattrnumber
        (
            itemtype    => itemtype,
            itemkey     => itemkey,
            aname       => 'OBJECT_ID'
        );

        l_object_ovn := wf_engine.getitemattrnumber
        (
            itemtype    => itemtype,
            itemkey     => itemkey,
            aname       => 'OBJECT_VER'
        );


        l_orig_status := wf_engine.getitemattrnumber
        (
            itemtype    => itemtype,
            itemkey     => itemkey,
            aname       => 'ORG_STATUS_ID'
        );


        OPEN get_ue_mel_cdl_details(l_object_id);
        FETCH get_ue_mel_cdl_details into l_ue_mel_cdl_details_rec;
        IF (get_ue_mel_cdl_details%NOTFOUND OR l_mel_cdl_rec.object_version_number <> l_object_ovn)
        THEN
            CLOSE get_ue_mel_cdl_details;

            fnd_message.set_name('AHL', 'AHL_MEL_CDL_NTF_ID_INVALID');
            fnd_message.set_token('HDR_ID', l_object_id, false);
            fnd_msg_pub.add;

            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
            THEN
                fnd_log.message
                (
                    fnd_log.level_exception,
                    l_debug_module,
                    false
                );
            END IF;

            resultout := 'COMPLETE:ERROR';
            RAISE FND_API.G_EXC_ERROR;

        END IF;
        CLOSE get_ue_mel_cdl_details;

        -- revert
        AHL_PRD_DF_PVT.process_approval_rejected(
                    p_unit_deferral_id      => l_object_id,
                    p_object_version_number => l_object_ovn,
                    p_new_status            => l_orig_status,
                    x_return_status         => l_return_status
                    );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
           fnd_log.string
	   	(
	   		fnd_log.level_statement,
			l_debug_module,
			'return status after process_approval_rejected API call : ' || l_return_status
		);
        END IF;

        IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            COMMIT WORK;
        END IF;

        resultout := 'COMPLETE:SUCCESS';

    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL')
    THEN
        resultout := 'COMPLETE:';
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT')
    THEN
        resultout := 'COMPLETE:';
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => itemtype,
            p_itemkey           => itemkey,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_REVERT_STATUS',
            itemtype,
            itemkey,
            actid,
            funcmode,
            l_error_msg
        );
        resultout := 'COMPLETE:ERROR';
        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_REVERT_STATUS',
            itemtype,
            itemkey,
            actid,
            'Unexpected Error! '||SUBSTR(SQLERRM,1,240)
        );
        RAISE;

END NR_REVERT_STATUS;

-- procedure to revert NR status and workorder status.
PROCEDURE NR_Rollback_Status (p_unit_deferral_id  IN NUMBER,
                              p_unit_deferral_ovn IN NUMBER,
                              p_new_status        IN NUMBER,
                              p_itemtype          IN VARCHAR2,
                              p_itemkey           IN VARCHAR2,
                              p_actid             IN NUMBER,
                              p_funcmode          IN VARCHAR2,
                              x_resultout         OUT NOCOPY VARCHAR2)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.NR_Rollback_Status';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_error_msg                 VARCHAR2(2000);

BEGIN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
           fnd_log.string
                (
                        fnd_log.level_statement,
                        'NR_Rollback_Status',
                        'Start of API call'
                );
        END IF;
        -- revert
        AHL_PRD_DF_PVT.process_approval_rejected(
                    p_unit_deferral_id      => p_unit_deferral_id,
                    p_object_version_number => p_unit_deferral_ovn,
                    p_new_status            => p_new_status,
                    x_return_status         => l_return_status
                    );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
           fnd_log.string
                (
                        fnd_log.level_statement,
                        l_debug_module,
                        'return status after process_approval_rejected API call : ' || l_return_status
                );
        END IF;

        IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            COMMIT WORK;
        END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (
            p_encoded   => FND_API.G_FALSE,
            p_count     => l_msg_count,
            p_data      => l_msg_data
        );

        AHL_GENERIC_APRV_PVT.handle_error
        (
            p_itemtype          => p_itemtype,
            p_itemkey           => p_itemkey,
            p_msg_count         => l_msg_count,
            p_msg_data          => l_msg_data,
            p_attr_name         => 'ERROR_MSG',
            x_error_msg         => l_error_msg
        );

        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_exception,
                l_debug_module,
                l_error_msg
            );
        END IF;

        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_REVERT_STATUS',
            p_itemtype,
            p_itemkey,
            p_actid,
            p_funcmode,
            l_error_msg
        );
        x_resultout := 'COMPLETE:ERROR';

        RAISE;

    WHEN OTHERS THEN
        wf_core.context
        (
            'AHL_MEL_CDL_APPROVALS_PVT',
            'NR_REVERT_STATUS',
            p_itemtype,
            p_itemkey,
            p_actid,
            'Unexpected Error! '||SUBSTR(SQLERRM,1,240)
        );
        x_resultout := 'COMPLETE:ERROR';

        RAISE;

END NR_Rollback_Status;

End AHL_MEL_CDL_APPROVALS_PVT;

/
