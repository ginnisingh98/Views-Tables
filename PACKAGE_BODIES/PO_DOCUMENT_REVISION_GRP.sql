--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_REVISION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_REVISION_GRP" AS
/* $Header: POXDOCRB.pls 120.4.12010000.23 2014/04/23 08:15:35 jiarsun ship $ */

-- Global Variables
G_PKG_NAME CONSTANT VARCHAR2(30) := 'PO_DOCUMENT_REVISION_GRP';

c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.';

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
--

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*                      Private Function Definition                        */
/*                                                                         */
/* ----------------------------------------------------------------------- */

FUNCTION PO_Archive_Check(p_doc_id IN NUMBER) return boolean;

FUNCTION Release_Archive_Check(p_doc_id IN NUMBER) return boolean;

PROCEDURE Compare_Table(
    p_doc_id           IN NUMBER,
    p_doc_subtype      IN VARCHAR2,
    p_type             IN VARCHAR2,
    p_element          IN VARCHAR2,
    p_line_id          IN NUMBER,          --<CancelPO FPJ>
    p_line_location_id IN NUMBER,          --<CancelPO FPJ>
    p_chk_cancel_flag  IN VARCHAR2,        --<CancelPO FPJ>
    x_different        IN OUT NOCOPY Varchar2);

/* ----------------------------------------------------------------------- */



PROCEDURE Check_New_Revision (p_api_version          IN  NUMBER,
                  p_doc_type         IN Varchar2,
                              p_doc_subtype          IN Varchar2,
                              p_doc_id              IN Number,
                              p_table_name          IN  Varchar2,
                  x_return_status        OUT NOCOPY VARCHAR2,
                              x_doc_revision_num     IN OUT NOCOPY Number,
                  x_message          IN OUT NOCOPY VARCHAR2) IS
l_need_new_revision boolean := FALSE;
l_progress varchar2(3);
l_api_version   CONSTANT NUMBER       := 1.0;
l_api_name      CONSTANT VARCHAR2(30) := 'Check_New_Revision';
l_different     Varchar2(1); --<CancelPO FPJ>
-- Bug 3616320 START
l_doc_type	   VARCHAR2(20);
l_keep_summary     VARCHAR2(1);
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_return_status    VARCHAR2(1);
-- Bug 3616320 END

begin

    l_progress := '000';
    -- Standard call to check for call compatibility

    IF (NOT FND_API.Compatible_API_Call(l_api_version
                       ,p_api_version
                       ,l_api_name
                       ,G_PKG_NAME))
    THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Check the required fields */
    If ((p_doc_type is NULL) OR(p_doc_subtype is NULL) OR
        (p_doc_id IS NULL)) THEN
        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_DOCUMENT_REVISION_GRP',
                               token2 => 'ERR_NUMBER',
                               value2 => '010',
                               token3 => 'SUBROUTINE',
                               value3 => 'Check_New_Revision()');

    end if; /*p_doc_type is NULL) OR(p_doc_subtype is NULL */

    l_progress := '020';
    /* Check if a valid table value was given */
    if ((p_table_name <> 'ALL') AND (p_table_name <> 'HEADER') AND
        (p_table_name <> 'LINES') AND (p_table_name <> 'SHIPMENTS') AND
        (p_table_name <> 'PO_LINE_PRICE_DIFF') AND (p_table_name <> 'PO_PB_PRICE_DIFF') AND -- SERVICES FPJ
        (p_table_name <> 'DISTRIBUTIONS')) THEN
        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_DOCUMENT_REVISION_GRP',
                               token2 => 'ERR_NUMBER',
                               value2 => '030',
                               token3 => 'SUBROUTINE',
                               value3 => 'Check_New_Revision()');

    end if; /*(p_table_name <> 'ALL') AND ((p_table_name <> 'HEADER') */

    l_progress := '040';
    if ((p_doc_type = 'PO') OR (p_doc_type = 'PA')) THEN
        l_need_new_revision :=
            Check_PO_PA_Revision(
                p_doc_id           => p_doc_id,
                p_doc_subtype      => p_doc_subtype,
                p_doc_type         => p_doc_type,
                p_table_name       => p_table_name,
                p_line_id          => NULL,              --<CancelPO FPJ>
                p_line_location_id => NULL,              --<CancelPO FPJ>
                p_chk_cancel_flag  => 'Y',               --<CancelPO FPJ>
                x_different        => l_different);      --<CancelPO FPJ>
    elsif ((p_doc_type = 'RELEASE')) THEN
        l_need_new_revision :=
            Check_Release_Revision(
                p_doc_id           => p_doc_id,
                p_doc_subtype      => p_doc_subtype,
                p_doc_type         => p_doc_type,
                p_table_name       => p_table_name,
                p_line_location_id => NULL,          --<CancelPO FPJ>
                p_chk_cancel_flag  => 'Y',           --<CancelPO FPJ>
                x_different        => l_different);  --<CancelPO FPJ>
    else
        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_DOCUMENT_REVISION_GRP',
                               token2 => 'ERR_NUMBER',
                               value2 => '040',
                               token3 => 'SUBROUTINE',
                               value3 => 'Check_New_Revision()');

    end if;  /* (p_doc_type = 'PO') OR (p_doc_type = 'PA') */

    if (l_need_new_revision) then
        --DISPLAY THE MESSAGE IN THE PLDS
        x_doc_revision_num := x_doc_revision_num + 1;
                x_message:= 'PO_REV_POXCH_NEW_REV';
         --<DBI Req Fulfillment 11.5.11 Start >
         if   ((p_doc_type = 'PO') OR (p_doc_type = 'PA')) THEN
               update po_headers
               set submit_date = NULL
               where po_header_id = p_doc_id;

         elsif ((p_doc_type = 'RELEASE')) THEN
               update po_releases
               set submit_date = NULL
               where po_release_id = p_doc_id;
         end if;
         --<DBI Req Fulfillment 11.5.11 End >

       -- Bug 3616320 START
       -- Only clear amendment for PO/PA
       IF ((p_doc_type = 'PO') OR (p_doc_type = 'PA')) THEN

         -- p_doc_type is always passed as 'PO' regardless of the subtype
         -- Should set doc_type to PA for Blanket and Contract
         IF (p_doc_subtype IN ('BLANKET', 'CONTRACT')) THEN
           l_doc_type := 'PA';
         ELSE
           l_doc_type := 'PO';
         END IF; /*IF (p_doc_subtype IN ('BLANKET', 'CONTRACT'))*/

         -- Call Clear_Amendment at the time of creating new revision.
         -- o If the pervious version is approved or require-reapproval
         --   the call OKC_TERMS_VERSION_GRP.CLEAR_AMENDMENT() with
         --   p_keey_summary = 'N'
         -- o Else call OKC_TERMS_VERSION_GRP.CLEAR_AMENDMENT() with
         --   p_keey_summary = 'Y'
         BEGIN
           SELECT 'N'
           INTO   l_keep_summary
           FROM   dual
           WHERE  exists (SELECT 'approved document'
                          FROM   po_headers
                          WHERE  po_header_id = p_doc_id
                          AND    NVL(approved_flag, 'N') IN ('R', 'Y'));
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             l_keep_summary := 'Y';
         END;


         IF g_fnd_debug = 'Y' THEN
	   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
	     FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name||'.'
	     || l_progress, 'Call OKC_TERMS_VERSION_GRP.clear_amendment '
	     || ' p_doc_id:' || p_doc_id
	     || ' p_doc_type:' || (l_doc_type ||'_'||p_doc_subtype)
	     || ' p_keep_summary:' || l_keep_summary);
	   END IF;
	 END IF;

         -- Calls Contracts API to clear Amendment related columns
         OKC_TERMS_VERSION_GRP.clear_amendment(
           p_api_version   => 1.0,
           p_init_msg_list => FND_API.G_FALSE,
           p_commit        => FND_API.G_FALSE,
           x_return_status => l_return_status,
           x_msg_data      => l_msg_data,
           x_msg_count     => l_msg_count,
           p_doc_type      => (l_doc_type ||'_'||p_doc_subtype),
           p_doc_id        => p_doc_id,
           p_keep_summary  => l_keep_summary);

       END IF; /*IF ((p_doc_type = 'PO') OR (p_doc_type = 'PA'))*/
       -- Bug 3616320 END
    end if;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    PO_MESSAGE_S.SQL_ERROR(routine => 'Check_New_Revision',
                             location => l_progress,
                             error_code => SQLCODE);

END Check_New_Revision;

FUNCTION Check_PO_PA_Revision (
    p_doc_type         IN Varchar2,
    p_doc_subtype      IN Varchar2,
    p_doc_id           IN Number,
    p_table_name       IN  Varchar2,
    p_line_id          IN NUMBER,          --<CancelPO FPJ>
    p_line_location_id IN NUMBER,          --<CancelPO FPJ>
    p_chk_cancel_flag  IN VARCHAR2,        --<CancelPO FPJ>
    x_different        OUT NOCOPY Varchar2 --<CancelPO FPJ>
) RETURN BOOLEAN IS
l_need_to_check boolean;
l_progress varchar2(3);
begin

    l_progress := '000';
    if ((p_doc_subtype <> 'STANDARD') AND (p_doc_subtype <> 'PLANNED') AND
        (p_doc_subtype <> 'BLANKET') AND (p_doc_subtype <> 'CONTRACT')) THEN
        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_DOCUMENT_REVISION_GRP',
                               token2 => 'ERR_NUMBER',
                               value2 => '010',
                               token3 => 'SUBROUTINE',
                               value3 => 'Check_PO_PA_Revision()');
        return FALSE;

    end if; /*(p_doc_subtype<>'STANDARD') AND (p_doc_subtype<>'PLANNED') */
    /* Check whether the header revision is same as the archived
     * Revision. If it is different then dont continue.
    */
    l_progress := '020';

    IF p_chk_cancel_flag = 'Y' THEN --<CancelPO FPJ>
    --IF Check Cancel Flag is N, then compare all invidual attributes except cancel flag

        l_need_to_check := PO_Archive_Check(p_doc_id);

        if (not l_need_to_check) then
            --If current revision is higher than archived, Header is different
            x_different := 'Y'; --<CancelPO FPJ>
            return FALSE;
        end if;

    END IF; -- End of IF p_chk_cancel_flag = 'Y' --<CancelPO FPJ>

    l_progress := '030';
    /*  All PO/PA types need to have their header checked
     *  when p_table_name in ('ALL', 'HEADER').
        */
    if ((p_table_name ='ALL') OR (p_table_name = 'HEADER')) THEN
            compare_table(p_doc_id           => p_doc_id,
                          p_doc_subtype      => p_doc_subtype,
                          p_type             => 'PORCH_PO',
                          p_element          => 'PORCH_HEADER',
                          p_line_id          => p_line_id,          --<CancelPO FPJ>
                          p_line_location_id => p_line_location_id, --<CancelPO FPJ>
                          p_chk_cancel_flag  => p_chk_cancel_flag,  --<CancelPO FPJ>
                          x_different        => x_different);

        if (x_different = 'Y') then
            return TRUE;
        end if;

        --< Shared Proc FPJ Start >
        IF (p_doc_subtype IN ('BLANKET', 'CONTRACT')) AND
           (PO_GA_PVT.is_global_agreement(p_doc_id))
        THEN
            compare_table(p_doc_id           => p_doc_id,
                          p_doc_subtype      => p_doc_subtype,
                          p_type             => 'PORCH_PO',
                          p_element          => 'PORCH_GA_ORG_ASSIGN',
                          p_line_id          => p_line_id,          --<CancelPO FPJ>
                          p_line_location_id => p_line_location_id, --<CancelPO FPJ>
                          p_chk_cancel_flag  => p_chk_cancel_flag,  --<CancelPO FPJ>
                          x_different        => x_different);

            IF (x_different = 'Y') THEN
                RETURN TRUE;
            END IF;

        END IF;  --< if PA and global agreement >
        --< Shared Proc FPJ End >

    END IF; /*(p_table_name ='ALL' OR (p_table_name = 'HEADER') */


    l_progress := '040';

    if ((p_table_name ='ALL') OR (p_table_name = 'LINES')) THEN
        if ((p_doc_subtype = 'STANDARD') OR
             (p_doc_subtype = 'PLANNED') OR
             (p_doc_subtype = 'BLANKET')) THEN
            compare_table(p_doc_id           => p_doc_id,
                          p_doc_subtype      => p_doc_subtype,
                          p_type             => 'PORCH_PO',
                          p_element          => 'PORCH_LINES',
                          p_line_id          => p_line_id,          --<CancelPO FPJ>
                          p_line_location_id => p_line_location_id, --<CancelPO FPJ>
                          p_chk_cancel_flag  => p_chk_cancel_flag,  --<CancelPO FPJ>
                          x_different        => x_different);
        end if; /*p_doc_subtype = 'STANDARD') OR ...*/

        if (x_different = 'Y') then
            return TRUE;
        end if;
    END IF; /*(p_table_name ='ALL' OR (p_table_name = 'LINES')*/

    /* Subtypes STANDARD and PLANNED and BLANKET need to have
         * their shipments checked if p_table_name in ('ALL', 'SHIPMENTS').
        */

    l_progress := '050';
    if ((p_table_name ='ALL') OR (p_table_name = 'SHIPMENTS')) THEN
        if ((p_doc_subtype = 'STANDARD') OR
             (p_doc_subtype = 'PLANNED')) THEN
            compare_table(p_doc_id           => p_doc_id,
                          p_doc_subtype      => p_doc_subtype,
                          p_type             => 'PORCH_PO',
                          p_element          => 'PORCH_SHIPMENTS',
                          p_line_id          => p_line_id,          --<CancelPO FPJ>
                          p_line_location_id => p_line_location_id, --<CancelPO FPJ>
                          p_chk_cancel_flag  => p_chk_cancel_flag,  --<CancelPO FPJ>
                          x_different        => x_different);
            if (x_different = 'Y') then
                return TRUE;
            end if;

        elsif (p_doc_subtype = 'BLANKET') THEN
            compare_table(p_doc_id           => p_doc_id,
                          p_doc_subtype      => p_doc_subtype,
                          p_type             => 'PORCH_PO',
                          p_element          => 'PORCH_PBREAK',
                          p_line_id          => p_line_id,          --<CancelPO FPJ>
                          p_line_location_id => p_line_location_id, --<CancelPO FPJ>
                          p_chk_cancel_flag  => p_chk_cancel_flag,  --<CancelPO FPJ>
                          x_different        => x_different);
            if (x_different = 'Y') then
                return TRUE;
            end if;
        end if; /*p_doc_subtype = 'STANDARD') OR ...*/

    END IF; /*(p_table_name ='ALL' OR (p_table_name = 'SHIPMENTS')*/

        -- SERVICES FPJ Start
        -- Check the price differentials table for standard PO's and GA's

        l_progress := '060';
        IF p_table_name = 'PO_LINE_PRICE_DIFF'
        THEN
            IF (p_doc_subtype = 'STANDARD') OR
               (PO_GA_PVT.is_global_agreement(p_doc_id))
            THEN
            compare_table(p_doc_id           => p_doc_id,
                          p_doc_subtype      => p_doc_subtype,
                          p_type             => 'PORCH_PO',
                          p_element          => 'PORCH_LINE_PRICE_DIFF',
                          p_line_id          => p_line_id,          --<CancelPO FPJ>
                          p_line_location_id => p_line_location_id, --<CancelPO FPJ>
                          p_chk_cancel_flag  => p_chk_cancel_flag,  --<CancelPO FPJ>
                          x_different        => x_different);
            END IF;

            IF (x_different = 'Y') THEN
                RETURN TRUE;
            END IF;

        END IF;

        l_progress := '070';
        IF p_table_name = 'PO_PB_PRICE_DIFF'
        THEN
            IF (PO_GA_PVT.is_global_agreement(p_doc_id))
            THEN
            compare_table(p_doc_id           => p_doc_id,
                          p_doc_subtype      => p_doc_subtype,
                          p_type             => 'PORCH_PO',
                          p_element          => 'PORCH_PB_PRICE_DIFF',
                          p_line_id          => p_line_id,          --<CancelPO FPJ>
                          p_line_location_id => p_line_location_id, --<CancelPO FPJ>
                          p_chk_cancel_flag  => p_chk_cancel_flag,  --<CancelPO FPJ>
                          x_different        => x_different);
            END IF;

            IF (x_different = 'Y') THEN
                RETURN TRUE;
            END IF;

        END IF;
        -- SERVICES FPJ End

    l_progress := '080';
    if ((p_table_name ='ALL') OR (p_table_name = 'DISTRIBUTIONS')) THEN
        if ((p_doc_subtype = 'STANDARD') OR
             (p_doc_subtype = 'PLANNED')) THEN
            compare_table(p_doc_id           => p_doc_id,
                          p_doc_subtype      => p_doc_subtype,
                          p_type             => 'PORCH_PO',
                          p_element          => 'PORCH_DISTRIBUTIONS',
                          p_line_id          => p_line_id,          --<CancelPO FPJ>
                          p_line_location_id => p_line_location_id, --<CancelPO FPJ>
                          p_chk_cancel_flag  => p_chk_cancel_flag,  --<CancelPO FPJ>
                          x_different        => x_different);
        end if; /*p_doc_subtype = 'STANDARD') OR ...*/

        if (x_different = 'Y') then
            return TRUE;
        end if;
    END IF; /*(p_table_name ='ALL' OR (p_table_name = 'DISTRIBUTIONS')*/

    return FALSE;
EXCEPTION
when others then
PO_MESSAGE_S.SQL_ERROR(routine => 'Check_PO_PA_Revision',
                             location => l_progress,
                             error_code => SQLCODE);

return(FALSE);
END Check_PO_PA_Revision;

FUNCTION Check_Release_Revision (
    p_doc_type         IN Varchar2,
    p_doc_subtype      IN Varchar2,
    p_doc_id           IN Number,
    p_table_name       IN  Varchar2,
    p_line_location_id IN NUMBER,           --<CancelPO FPJ>
    p_chk_cancel_flag  IN VARCHAR2,         --<CancelPO FPJ>
    x_different        OUT NOCOPY Varchar2) --<CancelPO FPJ>
RETURN BOOLEAN IS
l_need_to_check boolean;
l_progress varchar2(3);
begin

    l_progress := '000';
    if ((p_doc_subtype <> 'SCHEDULED')
            AND (p_doc_subtype <> 'BLANKET')) THEN
        PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                               token1 => 'FILE',
                               value1 => 'PO_DOCUMENT_REVISION_GRP',
                               token2 => 'ERR_NUMBER',
                               value2 => '010',
                               token3 => 'SUBROUTINE',
                               value3 => 'Check_Release_Revision()');
        return FALSE;

    end if;

    IF p_chk_cancel_flag = 'Y' THEN --<CancelPO FPJ>
    --IF Check Cancel Flag is N, then compare all invidual attributes except cancel flag

        l_need_to_check := Release_Archive_Check(p_doc_id);

        if (not l_need_to_check) then
            --If current revision is higher than archived, Header is different
            x_different := 'Y'; --<CancelPO FPJ>
            return FALSE;
        end if;

    END IF; -- End of IF p_chk_cancel_flag = 'Y' --<CancelPO FPJ>

    /*  All RELEASE types need to have their header checked
            if p_table_name in ('ALL', 'HEADER').
         */
    l_progress := '010';
     if ((p_table_name ='ALL') OR (p_table_name = 'HEADER')) THEN
            compare_table(p_doc_id           => p_doc_id,
                          p_doc_subtype      => p_doc_subtype,
                          p_type             => 'PORCH_RELEASE',
                          p_element          => 'PORCH_HEADER',
                          p_line_id          => NULL,          --<CancelPO FPJ>
                          p_line_location_id => p_line_location_id, --<CancelPO FPJ>
                          p_chk_cancel_flag  => p_chk_cancel_flag,  --<CancelPO FPJ>
                          x_different        => x_different);

                if (x_different = 'Y') then
                        return TRUE;
                end if;
        END IF; /*(p_table_name ='ALL' OR (p_table_name = 'HEADER') */

    /*  All RELEASE types need to have their shipments checked.
            if p_table_name in ('ALL', 'SHIPMENTS').
            */
    l_progress := '020';

     if ((p_table_name ='ALL') OR (p_table_name = 'SHIPMENTS')) THEN
            compare_table(p_doc_id           => p_doc_id,
                          p_doc_subtype      => p_doc_subtype,
                          p_type             => 'PORCH_RELEASE',
                          p_element          => 'PORCH_SHIPMENTS',
                          p_line_id          => NULL,          --<CancelPO FPJ>
                          p_line_location_id => p_line_location_id, --<CancelPO FPJ>
                          p_chk_cancel_flag  => p_chk_cancel_flag,  --<CancelPO FPJ>
                          x_different        => x_different);

                if (x_different = 'Y') then
                        return TRUE;
                end if;
         END IF; /*(p_table_name ='ALL' OR (p_table_name = 'SHIPMENTS') */


    /*  All RELEASE types need to have their distributions checked
            if p_table_name in ('ALL', 'DISTRIBUTIONS').
         */
    l_progress := '030';

     if ((p_table_name ='ALL') OR (p_table_name = 'DISTRIBUTIONS')) THEN
            compare_table(p_doc_id           => p_doc_id,
                          p_doc_subtype      => p_doc_subtype,
                          p_type             => 'PORCH_RELEASE',
                          p_element          => 'PORCH_DISTRIBUTIONS',
                          p_line_id          => NULL,          --<CancelPO FPJ>
                          p_line_location_id => p_line_location_id, --<CancelPO FPJ>
                          p_chk_cancel_flag  => p_chk_cancel_flag,  --<CancelPO FPJ>
                          x_different        => x_different);

                if (x_different = 'Y') then
                        return TRUE;
                end if;
        END IF; /*(p_table_name ='ALL' OR (p_table_name = 'DISTRIBUTIONS') */
    return FALSE;
EXCEPTION
when others then
PO_MESSAGE_S.SQL_ERROR(routine => 'Check_Release_Revision',
                             location => l_progress,
                             error_code => SQLCODE);

return(FALSE);
END Check_Release_Revision;

/*******************************************************************
  FUNCTION NAME: PO_Archive_Check

  DESCRIPTION   : Called from Check_PO_PA_Revision function.

  Algr: Selects the revision number of the po_header and the latest
        archived version (when it exists) and compares them.
        If current revision_num = latest revision_num
             return FALSE
        Else
             return  TRUE
        In case of a sql error need_to_check will be FALSE

  Referenced by :
  parameters    :  p_doc_Id     IN  NUMBER - Document Id.

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/

FUNCTION PO_Archive_Check(p_doc_id IN NUMBER)
RETURN BOOLEAN IS
l_revision_num po_headers_all.revision_num%type;
l_archived_number po_headers_archive.revision_num%type;
l_need_to_check boolean;
l_progress varchar2(3);
begin
    l_progress := '000';
    SELECT POH.revision_num, nvl(POHA.revision_num, -1)
    into l_revision_num, l_archived_number
    FROM   PO_HEADERS POH,
               PO_HEADERS_ARCHIVE POHA
        WHERE  POH.po_header_id = p_doc_id
        AND    POH.po_header_id = POHA.po_header_id (+)
        AND    POHA.latest_external_flag (+) = 'Y';

    if (l_revision_num <> l_archived_number) then
        l_need_to_check := FALSE;
    else
        l_need_to_check := TRUE;
    end if;
    return l_need_to_check;

EXCEPTION
when others then
PO_MESSAGE_S.SQL_ERROR(routine => 'PO_Archive_Check',
                             location => l_progress,
                             error_code => SQLCODE);

return(FALSE);
END PO_Archive_Check;

/*******************************************************************
  FUNCTION NAME: Release_Archive_Check

  DESCRIPTION   : Called from Check_PO_PA_Revision function.

  Algr: Selects the revision number of the po_header and the latest
        archived version (when it exists) and compares them.
        If current revision_num <> latest revision_num
             return FALSE
        Else
             return  TRUE
        In case of a sql error need_to_check will be FALSE

  Referenced by :
  parameters    :  p_doc_Id     IN  NUMBER - Document Id.

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/

FUNCTION Release_Archive_Check(p_doc_id IN NUMBER)
RETURN BOOLEAN IS
l_revision_num po_headers_all.revision_num%type;
l_archived_number po_headers_archive.revision_num%type;
l_need_to_check boolean;
l_progress varchar2(3);
begin

    l_progress := '000';
        SELECT POR.revision_num, nvl(PORA.revision_num, -1)
        INTO   l_revision_num, l_archived_number
        FROM   PO_RELEASES POR,
               PO_RELEASES_ARCHIVE PORA
        WHERE  POR.po_release_id = p_doc_id
        AND    POR.po_release_id = PORA.po_release_id (+)
        AND    PORA.latest_external_flag (+) = 'Y';

    if (l_revision_num <> l_archived_number) then
        l_need_to_check := FALSE;
    else
        l_need_to_check := TRUE;
    end if;
    return l_need_to_check;

EXCEPTION
when others then
PO_MESSAGE_S.SQL_ERROR(routine => 'Release_Archive_Check',
                             location => l_progress,
                             error_code => SQLCODE);

return(FALSE);
END Release_Archive_Check;


/*******************************************************************
  PROCEDURE NAME: Compare_Table

  DESCRIPTION   : Called from Check_PO_PA_Revision function.

  Algr: Compare the requested table with the latest archived version
        If they are different then
           return x_different = Y
        Else
           return x_different = N

  Referenced by :
  parameters    :  p_doc_Id     IN  NUMBER - Document Id.
               p_doc_subtype IN VARCHAR2,
           p_type       IN VARCHAR2, -- PO or RELEASE
                   p_element    IN VARCHAR2) -- Header or Lines etc
                   x_different    IN VARCHAR2)

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/

PROCEDURE Compare_Table(
    p_doc_id           IN NUMBER,
    p_doc_subtype      IN VARCHAR2,
    p_type             IN VARCHAR2,
    p_element          IN VARCHAR2,
    p_line_id          IN NUMBER,          --<CancelPO FPJ>
    p_line_location_id IN NUMBER,          --<CancelPO FPJ>
    p_chk_cancel_flag  IN VARCHAR2,        --<CancelPO FPJ>
    x_different        IN OUT NOCOPY Varchar2) IS

l_progress varchar2(3);
l_accepted_flag varchar2(1);  -- Bug 3388218

begin

    l_progress := '000';
    if (p_type = 'PORCH_PO') then

        l_progress := '010';
        if (p_element = 'PORCH_HEADER') then
/* Start Bug# 5943064, We need to consider 3 cases. I Supplier portal
 	    if the PO is 'Accepted'/'Rejected'  then we set the acceptance_required_flag
 	    to 'N' so that we dont Enter any more acceptances.the accepted_flag can be 'Y'/'N'.
 	    But when creating the document revision we were not considering that
 	    accepted_flag can be 'N' when rejected and we should cause a document revision
 	    when this change happens and these documents can be cancelled.
 	    So we are now checking if the document is both Accepted and Rejected cases and
 	    since normal Accetances also have 'N' we differentiate a 'Rejected' case
 	    by also looking at the acceptance_required_flag in the po_headers table.
 	    Doing the same for the acceptance_due_date. l_accepted_flag='X' will
 	    represent lines which dont have acceptance Entered. */

          -- Bug 3388218 Start
            Begin
                Select pav.accepted_flag
                into l_accepted_flag
                from po_acceptances_v pav,
                     po_headers poh
                where poh.po_header_id=p_doc_id
                and poh.po_header_id=pav.po_header_id
                and pav.revision_num= poh.revision_num
                and poh.acceptance_required_flag='N'
                and rownum=1;
                 --and pav.accepted_flag='Y';
            Exception
                when others then
                    l_accepted_flag:='X';
            End;
          -- Bug 3388218 End
           --End Bug# 5943064

/*Bug5154626: cancel action on the PO's in approved state errors out on which
  Mass update buyer program is run before to update buyer name.
  Hence donot use the agent_id comparision for cancel flow*/

            Select 'Y'
            INTO   x_different
            from sys.dual
            where exists(
            select null
            FROM   PO_HEADERS POH,
            PO_HEADERS_ARCHIVE POHA
            WHERE  POH.po_header_id = p_doc_id
            AND    POH.po_header_id = POHA.po_header_id (+)
            AND    POHA.latest_external_flag (+) = 'Y'
            AND   (
                  ( POHA.po_header_id IS NULL)
            OR ( (POH.agent_id <> POHA.agent_id) AND  (p_chk_cancel_flag='Y'))
            OR (POH.vendor_site_id <> POHA.vendor_site_id)
            OR (POH.vendor_site_id IS NULL
                 AND POHA.vendor_site_id IS NOT NULL)
            OR (POH.vendor_site_id IS NOT NULL
                 AND POHA.vendor_site_id IS NULL)
            OR (POH.vendor_contact_id <> POHA.vendor_contact_id)
            OR (POH.vendor_contact_id IS NULL
                 AND POHA.vendor_contact_id IS NOT NULL)
            OR (POH.vendor_contact_id IS NOT NULL
                 AND POHA.vendor_contact_id IS NULL)
            OR (POH.ship_to_location_id <> POHA.ship_to_location_id)
            OR (POH.ship_to_location_id IS NULL
                 AND POHA.ship_to_location_id IS NOT NULL)
            OR (POH.ship_to_location_id IS NOT NULL
                 AND POHA.ship_to_location_id IS NULL)
            OR (POH.bill_to_location_id <> POHA.bill_to_location_id)
            OR (POH.bill_to_location_id IS NULL
                 AND POHA.bill_to_location_id IS NOT NULL)
            OR (POH.bill_to_location_id IS NOT NULL
                 AND POHA.bill_to_location_id IS NULL)
            OR (POH.terms_id <> POHA.terms_id)
            OR (POH.terms_id IS NULL
                 AND POHA.terms_id IS NOT NULL)
            OR (POH.terms_id IS NOT NULL
                 AND POHA.terms_id IS NULL)
            OR (POH.ship_via_lookup_code <>
                POHA.ship_via_lookup_code)
            OR (POH.ship_via_lookup_code IS NULL
                 AND POHA.ship_via_lookup_code IS NOT NULL)
            OR (POH.ship_via_lookup_code IS NOT NULL
                 AND POHA.ship_via_lookup_code IS NULL)
            OR (POH.fob_lookup_code <> POHA.fob_lookup_code)
            OR (POH.fob_lookup_code IS NULL
                 AND POHA.fob_lookup_code IS NOT NULL)
            OR (POH.fob_lookup_code IS NOT NULL
                 AND POHA.fob_lookup_code IS NULL)
            OR (POH.freight_terms_lookup_code <>
                POHA.freight_terms_lookup_code)
            OR (POH.freight_terms_lookup_code IS NULL
                 AND POHA.freight_terms_lookup_code IS NOT NULL)
            OR (POH.freight_terms_lookup_code IS NOT NULL
                 AND POHA.freight_terms_lookup_code IS NULL)
                        -- <INBOUND LOGISTICS FPJ START>
                        OR (POH.shipping_control <>
                            POHA.shipping_control)
                        OR (POH.shipping_control IS NULL
                               AND POHA.shipping_control IS NOT NULL)
                        OR (POH.shipping_control IS NOT NULL
                               AND POHA.shipping_control IS NULL)
                        -- <INBOUND LOGISTICS FPJ END>
            OR (POH.blanket_total_amount <>
                POHA.blanket_total_amount)
            OR (POH.blanket_total_amount IS NULL
                 AND POHA.blanket_total_amount IS NOT NULL)
            OR (POH.blanket_total_amount IS NOT NULL
                 AND POHA.blanket_total_amount IS NULL)
            OR (POH.note_to_vendor <> POHA.note_to_vendor)
            OR (POH.note_to_vendor IS NULL
                 AND POHA.note_to_vendor IS NOT NULL)
            OR (POH.note_to_vendor IS NOT NULL
                 AND POHA.note_to_vendor IS NULL)
            OR (POH.confirming_order_flag <>
                POHA.confirming_order_flag)
            OR (POH.confirming_order_flag IS NULL
                 AND POHA.confirming_order_flag IS NOT NULL)
            OR (POH.confirming_order_flag IS NOT NULL
                 AND POHA.confirming_order_flag IS NULL)
        -- Start Bug 3659223: Clean up logic, and correctly handle
        -- revisioning for PO rejected during signature process.
        -- Replaced bug fix for bug 3388218
            OR ((POH.acceptance_required_flag <> POHA.acceptance_required_flag)
                   AND (POH.acceptance_required_flag <> 'N'))
            OR  (POHA.acceptance_required_flag in ('Y','D')
                   AND POH.acceptance_required_flag ='N'
                    AND (nvl(l_accepted_flag,'X') not in ('N', 'Y'))) --Bug# 5943064
        -- End Bug 3659223
            OR (POH.acceptance_required_flag IS NULL
                 AND POHA.acceptance_required_flag IS NOT NULL)
            OR (POH.acceptance_required_flag IS NOT NULL
                 AND POHA.acceptance_required_flag IS NULL)
            OR (POH.acceptance_due_date <> POHA.acceptance_due_date)
            OR (POH.acceptance_due_date IS NULL
                 AND POHA.acceptance_due_date IS NOT NULL
                 AND nvl(l_accepted_flag,'X') not in ('N','Y')  -- Bug 3498816, Bug# 5943064
                 -- Bug 3659223: Do not revision for Doc and Sig, as
                 -- accepting/rejecting will null out the date.
                 AND nvl(POH.acceptance_required_flag, 'X') <> 'S')
            OR (POH.acceptance_due_date IS NOT NULL
                 AND POHA.acceptance_due_date IS NULL)
            OR (POH.amount_limit <> POHA.amount_limit)
            OR (POH.amount_limit IS NULL
                 AND POHA.amount_limit IS NOT NULL)
            OR (POH.amount_limit IS NOT NULL
                 AND POHA.amount_limit IS NULL)
            OR (POH.start_date <> POHA.start_date)
            OR (POH.start_date IS NULL
                 AND POHA.start_date IS NOT NULL)
            OR (POH.start_date IS NOT NULL
                         AND POHA.start_date IS NULL)
            OR (POH.end_date <> POHA.end_date)
            OR (POH.end_date IS NULL
                 AND POHA.end_date IS NOT NULL)
            OR (POH.end_date IS NOT NULL
                 AND POHA.end_date IS NULL)
            OR (p_chk_cancel_flag = 'Y' AND --<CancelPO FPJ>
               ((POH.cancel_flag <> POHA.cancel_flag)
            OR (POH.cancel_flag IS NULL
                 AND POHA.cancel_flag IS NOT NULL)
            OR (POH.cancel_flag IS NOT NULL
                    AND POHA.cancel_flag IS NULL)))

            --<CONTERMS FPJ START> dependency popo.odf , poarc.odf
            OR (POH.conterms_articles_upd_date <> POHA.conterms_articles_upd_date)
            OR (POH.conterms_articles_upd_date IS NULL
                 AND POHA.conterms_articles_upd_date IS NOT NULL)
            OR (POH.conterms_articles_upd_date IS NOT NULL
                                 AND POHA.conterms_articles_upd_date IS NULL)
            OR (POH.conterms_deliv_upd_date <> POHA.conterms_deliv_upd_date)
            OR (POH.conterms_deliv_upd_date IS NULL
                 AND POHA.conterms_deliv_upd_date IS NOT NULL)
            OR (POH.conterms_deliv_upd_date IS NOT NULL
                                 AND POHA.conterms_deliv_upd_date IS NULL)

            --<CONTERMS FPJ END>
            ));

        --< Shared Proc FPJ Start >
        ELSIF (p_element = 'PORCH_GA_ORG_ASSIGN') AND
              (p_doc_subtype IN ('BLANKET', 'CONTRACT'))
        THEN

            l_progress := '015';

            --SQL What: Check latest external archived records with
            --  the current records
            --SQL Why: If certain columns are different, a new
            --  revision is needed
            SELECT 'Y'
              INTO x_different
              FROM po_ga_org_assignments pgoa,
                   po_ga_org_assignments_archive pgoaa
             WHERE pgoa.po_header_id = p_doc_id
               AND pgoa.po_header_id = pgoaa.po_header_id (+)
               AND pgoa.organization_id = pgoaa.organization_id (+)
               AND pgoaa.latest_external_flag (+) = 'Y'
               AND (   (pgoaa.po_header_id IS NULL)
                    OR (pgoaa.organization_id <> pgoa.organization_id)
                    OR (pgoaa.purchasing_org_id <> pgoa.purchasing_org_id)
                    OR (pgoaa.vendor_site_id <> pgoa.vendor_site_id)
                    OR (pgoaa.enabled_flag <> pgoa.enabled_flag)
                   )
               AND ROWNUM = 1;

        --< Shared Proc FPJ End >

        elsif (p_element = 'PORCH_LINES') then --p_element='PORCH_HEADER'*/

            l_progress := '020';
            if (p_doc_subtype = 'BLANKET') then
                Select 'Y'
                INTO   x_different
                from sys.dual
                where exists(
                select null
                 FROM  PO_LINES POL,
                 PO_LINES_ARCHIVE POLA
                 WHERE POL.po_header_id = p_doc_id
                 AND (p_line_id IS NULL OR POL.po_line_id = p_line_id) --<CancelPO FPJ>
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.line_num <> POLA.line_num)
                 OR (POL.item_id <> POLA.item_id)
                 OR (POL.item_id IS NULL
                    AND POLA.item_id IS NOT NULL)
                 OR (POL.item_id IS NOT NULL
                    AND POLA.item_id IS NULL)
                               -- SERVICES FPJ Start
                 OR (POL.job_id <> POLA.job_id)
                 OR (POL.job_id IS NULL
                    AND POLA.job_id IS NOT NULL)
                 OR (POL.job_id IS NOT NULL
                    AND POLA.job_id IS NULL)
                 OR (POL.amount <> POLA.amount)
                 OR (POL.amount IS NULL
                    AND POLA.amount IS NOT NULL)
                 OR (POL.amount IS NOT NULL
                    AND POLA.amount IS NULL)
                                -- SERVICES FPJ Start
                 OR (POL.item_revision <> POLA.item_revision)
                 OR (POL.item_revision IS NULL
                    AND POLA.item_revision IS NOT NULL)
                 OR (POL.item_revision IS NOT NULL
                    AND POLA.item_revision IS NULL)
                 OR (TRIM(POL.item_description) <>
                    TRIM(POLA.item_description)) --Bug14214404
                 OR (POL.item_description IS NULL
                   AND POLA.item_description IS NOT NULL)
                 OR (POL.item_description IS NOT NULL
                   AND POLA.item_description IS NULL)
                 OR (POL.unit_meas_lookup_code <>
                    POLA.unit_meas_lookup_code)
                 OR (POL.unit_meas_lookup_code IS NULL
                   AND POLA.unit_meas_lookup_code IS NOT NULL)
                 OR (POL.unit_meas_lookup_code IS NOT NULL
                   AND POLA.unit_meas_lookup_code IS NULL)
                 OR (POL.quantity_committed <>
                    POLA.quantity_committed)
                 OR (POL.quantity_committed IS NULL
                   AND POLA.quantity_committed IS NOT NULL)
                 OR (POL.quantity_committed IS NOT NULL
                   AND POLA.quantity_committed IS NULL)
                 OR (POL.committed_amount <>
                    POLA.committed_amount)
                 OR (POL.committed_amount IS NULL
                   AND POLA.committed_amount IS NOT NULL)
                 OR (POL.committed_amount IS NOT NULL
                       AND POLA.committed_amount IS NULL)
                 OR (POL.unit_price <> POLA.unit_price)
                 OR (POL.unit_price IS NULL
                    AND POLA.unit_price IS NOT NULL)
                 OR (POL.unit_price IS NOT NULL
                    AND POLA.unit_price IS NULL)
                 -- Bug 3471211
                 OR (POL.not_to_exceed_price <> POLA.not_to_exceed_price)
                 OR (POL.not_to_exceed_price IS NULL
                    AND POLA.not_to_exceed_price IS NOT NULL)
                 OR (POL.not_to_exceed_price IS NOT NULL
                    AND POLA.not_to_exceed_price IS NULL)
                 OR (POL.un_number_id <> POLA.un_number_id)
                 OR (POL.un_number_id IS NULL
                    AND POLA.un_number_id IS NOT NULL)
                 OR (POL.un_number_id IS NOT NULL
                    AND POLA.un_number_id IS NULL)
                 OR (POL.hazard_class_id <> POLA.hazard_class_id)
                 OR (POL.hazard_class_id IS NULL
                       AND POLA.hazard_class_id IS NOT NULL)
                 OR (POL.hazard_class_id IS NOT NULL
                       AND POLA.hazard_class_id IS NULL)
                 OR (POL.note_to_vendor <> POLA.note_to_vendor)
                 OR (POL.note_to_vendor IS NULL
                       AND POLA.note_to_vendor IS NOT NULL)
                 OR (POL.note_to_vendor IS NOT NULL
                       AND POLA.note_to_vendor IS NULL)
                 OR (POL.note_to_vendor <> POLA.note_to_vendor)
                 OR (POL.note_to_vendor IS NULL
                       AND POLA.note_to_vendor IS NOT NULL)
                 OR (POL.note_to_vendor IS NOT NULL
                       AND POLA.note_to_vendor IS NULL)
                 OR (POL.from_header_id <> POLA.from_header_id)
                 OR (POL.from_header_id IS NULL
                       AND POLA.from_header_id IS NOT NULL)
                 OR (POL.from_header_id IS NOT NULL
                       AND POLA.from_header_id IS NULL)
                 OR (POL.from_line_id <> POLA.from_line_id)
                 OR (POL.from_line_id IS NULL
                       AND POLA.from_line_id IS NOT NULL)
                 OR (POL.from_line_id IS NOT NULL
                       AND POLA.from_line_id IS NULL)
                 -- Bug 3305753: Closed code need not be compared
                 -- Since close action is an internal action and
                 -- should not affect the document revision.
                 --   ((POL.closed_code <> POLA.closed_code)
                 --OR (POL.closed_code IS NULL
                 --      AND POLA.closed_code IS NOT NULL)
                 --OR (POL.closed_code IS NOT NULL
                 --      AND POLA.closed_code IS NULL))
                 OR (POL.vendor_product_num <>
                    POLA.vendor_product_num)
                 OR (POL.vendor_product_num IS NULL
                   AND POLA.vendor_product_num IS NOT NULL)
                 OR (POL.vendor_product_num IS NOT NULL
                       AND POLA.vendor_product_num IS NULL)
                                 -- <GC FPJ>
                                 -- Removing CONTRACT_NUM check because
                                 -- Blanket line cannot reference a contract
                 OR (POL.price_type_lookup_code <>
                    POLA.price_type_lookup_code)
                 OR (POL.price_type_lookup_code IS NULL
                   AND POLA.price_type_lookup_code IS NOT NULL)
                 OR (POL.price_type_lookup_code IS NOT NULL
                    AND POLA.price_type_lookup_code IS NULL)
                 OR (POL.expiration_date IS NULL
                     AND POLA.expiration_date IS NOT NULL)
                 OR (POL.expiration_date IS NOT NULL
                     AND POLA.expiration_date IS NULL)
                 OR (trunc(POL.expiration_date) <>
                    trunc(POLA.expiration_date))
                 OR (p_chk_cancel_flag = 'Y' AND --<CancelPO FPJ>
                    ((POL.cancel_flag <> POLA.cancel_flag)
                 OR (POL.cancel_flag IS NULL
                        AND POLA.cancel_flag IS NOT NULL)
                 OR (POL.cancel_flag IS NOT NULL
                     AND POLA.cancel_flag IS NULL)))));


            else  -- (p_doc_subtype = 'BLANKET') */
                Select 'Y'
                INTO   x_different
                from sys.dual
                where exists(
                select null
                 FROM  PO_LINES POL,
                 PO_LINES_ARCHIVE POLA
                 WHERE POL.po_header_id = p_doc_id
                 AND (p_line_id IS NULL OR POL.po_line_id = p_line_id) --<CancelPO FPJ>
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.line_num <> POLA.line_num)
                 OR (POL.item_id <> POLA.item_id)
                 OR (POL.item_id IS NULL
                    AND POLA.item_id IS NOT NULL)
                 OR (POL.item_id IS NOT NULL
                    AND POLA.item_id IS NULL)
                              -- SERVICES FPJ Start
                 OR (POL.job_id <> POLA.job_id)
                 OR (POL.job_id IS NULL
                    AND POLA.job_id IS NOT NULL)
                 OR (POL.job_id IS NOT NULL
                    AND POLA.job_id IS NULL)
                 OR (POL.amount <> POLA.amount)
                 OR (POL.amount IS NULL
                    AND POLA.amount IS NOT NULL)
                 OR (POL.amount IS NOT NULL
                    AND POLA.amount IS NULL)
                 OR (POL.expiration_date IS NULL
                     AND POLA.expiration_date IS NOT NULL)
                 OR (POL.expiration_date IS NOT NULL
                     AND POLA.expiration_date IS NULL)
                 OR (trunc(POL.expiration_date) <>
                    trunc(POLA.expiration_date))
                 OR (POL.start_date IS NULL
                     AND POLA.start_date IS NOT NULL)
                 OR (POL.start_date IS NOT NULL
                     AND POLA.start_date IS NULL)
                 OR (trunc(POL.start_date) <>
                    trunc(POLA.start_date))
                 OR (POL.contractor_first_name <>
                    POLA.contractor_first_name)
                 OR (POL.contractor_first_name IS NULL
                   AND POLA.contractor_first_name IS NOT NULL)
                 OR (POL.contractor_first_name IS NOT NULL
                   AND POLA.contractor_first_name IS NULL)
                 OR (POL.contractor_last_name <>
                    POLA.contractor_last_name)
                 OR (POL.contractor_last_name IS NULL
                   AND POLA.contractor_last_name IS NOT NULL)
                 OR (POL.contractor_last_name IS NOT NULL
                   AND POLA.contractor_last_name IS NULL)
                             -- SERVICES FPJ Start
                 OR (POL.item_revision <> POLA.item_revision)
                 OR (POL.item_revision IS NULL
                    AND POLA.item_revision IS NOT NULL)
                 OR (POL.item_revision IS NOT NULL
                    AND POLA.item_revision IS NULL)
                 OR (TRIM(POL.item_description) <>
                    TRIM(POLA.item_description))  --Bug14214404
                 OR (POL.item_description IS NULL
                   AND POLA.item_description IS NOT NULL)
                 OR (POL.item_description IS NOT NULL
                   AND POLA.item_description IS NULL)
                 OR (POL.unit_meas_lookup_code <>
                    POLA.unit_meas_lookup_code)
                 OR (POL.unit_meas_lookup_code IS NULL
                   AND POLA.unit_meas_lookup_code IS NOT NULL)
                 OR (POL.unit_meas_lookup_code IS NOT NULL
                   AND POLA.unit_meas_lookup_code IS NULL)
                 OR (p_chk_cancel_flag = 'Y' AND  POL.quantity <> POLA.quantity) --<CancelPO FPJ>
                 OR (POL.quantity IS NULL
                       AND POLA.quantity IS NOT NULL)
                 OR (POL.quantity_committed <>
                    POLA.quantity_committed)
                 OR (POL.quantity_committed IS NULL
                   AND POLA.quantity_committed IS NOT NULL)
                 OR (POL.quantity_committed IS NOT NULL
                       AND POLA.quantity_committed IS NULL)
                 OR (POL.committed_amount <>
                    POLA.committed_amount)
                 OR (POL.committed_amount IS NULL
                       AND POLA.committed_amount IS NOT NULL)
                 OR (POL.committed_amount IS NOT NULL
                   AND POLA.committed_amount IS NULL)
                 OR (POL.unit_price <> POLA.unit_price)
                 OR (POL.unit_price IS NULL
                    AND POLA.unit_price IS NOT NULL)
                 OR (POL.unit_price IS NOT NULL
                    AND POLA.unit_price IS NULL)
                 -- Bug 3471211
                 OR (POL.not_to_exceed_price <> POLA.not_to_exceed_price)
                 OR (POL.not_to_exceed_price IS NULL
                    AND POLA.not_to_exceed_price IS NOT NULL)
                 OR (POL.not_to_exceed_price IS NOT NULL
                    AND POLA.not_to_exceed_price IS NULL)
                 OR (POL.un_number_id <> POLA.un_number_id)
                 OR (POL.un_number_id IS NULL
                    AND POLA.un_number_id IS NOT NULL)
                 OR (POL.un_number_id IS NOT NULL
                    AND POLA.un_number_id IS NULL)
                 OR (POL.hazard_class_id <>
                    POLA.hazard_class_id)
                 OR (POL.hazard_class_id IS NULL
                       AND POLA.hazard_class_id IS NOT NULL)
                 OR (POL.hazard_class_id IS NOT NULL
                       AND POLA.hazard_class_id IS NULL)
                 OR (POL.note_to_vendor <> POLA.note_to_vendor)
                 OR (POL.note_to_vendor IS NULL
                       AND POLA.note_to_vendor IS NOT NULL)
                 OR (POL.note_to_vendor IS NOT NULL
                       AND POLA.note_to_vendor IS NULL)
                 OR (POL.note_to_vendor <> POLA.note_to_vendor)
                 OR (POL.note_to_vendor IS NULL
                       AND POLA.note_to_vendor IS NOT NULL)
                 OR (POL.note_to_vendor IS NOT NULL
                       AND POLA.note_to_vendor IS NULL)
                 OR (POL.from_header_id <> POLA.from_header_id)
                 OR (POL.from_header_id IS NULL
                       AND POLA.from_header_id IS NOT NULL)
                 OR (POL.from_header_id IS NOT NULL
                       AND POLA.from_header_id IS NULL)
                 OR (POL.from_line_id <> POLA.from_line_id)
                 OR (POL.from_line_id IS NULL
                       AND POLA.from_line_id IS NOT NULL)
                 OR (POL.from_line_id IS NOT NULL
                       AND POLA.from_line_id IS NULL)
                 -- Bug 3305753:Closed code need not be compared
                 -- Since close action is an internal action and
                 -- should not affect the document revision.
                 --   ((POL.closed_code <> POLA.closed_code)
                 -- OR (POL.closed_code IS NULL
                 --      AND POLA.closed_code IS NOT NULL)
                 -- OR (POL.closed_code IS NOT NULL
                 --      AND POLA.closed_code IS NULL))
                 OR (POL.vendor_product_num <>
                    POLA.vendor_product_num)
                 OR (POL.vendor_product_num IS NULL
                   AND POLA.vendor_product_num IS NOT NULL)
                 OR (POL.vendor_product_num IS NOT NULL
                   AND POLA.vendor_product_num IS NULL)
                                 -- <GC FPJ>
                                 -- Compare contract_id instead of contract_num
                 OR (POL.contract_id <> POLA.contract_id)
                 OR (POL.contract_id IS NULL
                       AND POLA.contract_id IS NOT NULL)
                 OR (POL.contract_id IS NOT NULL
                       AND POLA.contract_id IS NULL)
                 OR (POL.price_type_lookup_code <>
                    POLA.price_type_lookup_code)
                 OR (POL.price_type_lookup_code IS NULL
                   AND POLA.price_type_lookup_code IS NOT NULL)
                 OR (POL.price_type_lookup_code IS NOT NULL
                    AND POLA.price_type_lookup_code IS NULL)
                 OR (p_chk_cancel_flag = 'Y' AND --<CancelPO FPJ>
                    ((POL.cancel_flag <> POLA.cancel_flag)
                 OR (POL.cancel_flag IS NULL
                        AND POLA.cancel_flag IS NOT NULL)
                 OR (POL.cancel_flag IS NOT NULL
                       AND POLA.cancel_flag IS NULL)))
                 -- <Complex Work R12 Start>
                 OR (POL.retainage_rate <> POLA.retainage_rate)
                 OR (POL.retainage_rate IS NULL
                    AND POLA.retainage_rate IS NOT NULL)
                 OR (POL.retainage_rate IS NOT NULL
                    AND POLA.retainage_rate IS NULL)
                 OR (POL.max_retainage_amount <> POLA.max_retainage_amount)
                 OR (POL.max_retainage_amount IS NULL
                    AND POLA.max_retainage_amount IS NOT NULL)
                 OR (POL.max_retainage_amount IS NOT NULL
                    AND POLA.max_retainage_amount IS NULL)
                 OR (POL.progress_payment_rate <> POLA.progress_payment_rate)
                 OR (POL.progress_payment_rate IS NULL
                    AND POLA.progress_payment_rate IS NOT NULL)
                 OR (POL.progress_payment_rate IS NOT NULL
                    AND POLA.progress_payment_rate IS NULL)
                 OR (POL.recoupment_rate <> POLA.recoupment_rate)
                 OR (POL.recoupment_rate IS NULL
                    AND POLA.recoupment_rate IS NOT NULL)
                 OR (POL.recoupment_rate IS NOT NULL
                    AND POLA.recoupment_rate IS NULL)
                 -- <Complex Work R12 End>
                 ));

            end if; -- (p_doc_subtype = 'BLANKET') */


        elsif(p_element = 'PORCH_SHIPMENTS') then --p_element='PORCH_HEADER'*/
            Select 'Y'
            INTO   x_different
            from sys.dual
            where exists(
            select null
               FROM  PO_LINE_LOCATIONS POLL,
                 PO_LINE_LOCATIONS_ARCHIVE POLLA
               WHERE POLL.po_header_id = p_doc_id
               AND  POLL.po_release_id is null    -- Bug 3876235
               AND (p_line_id IS NULL OR POLL.po_line_id = p_line_id) --<CancelPO FPJ>
               AND (p_line_location_id IS NULL OR POLL.line_location_id = p_line_location_id) --<CancelPO FPJ>
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
               (POLLA.line_location_id is NULL)
               OR (POLL.quantity <> POLLA.quantity)
               OR (POLL.quantity IS NULL AND POLLA.quantity IS NOT NULL)
               OR (POLL.quantity IS NOT NULL AND POLLA.quantity IS NULL)
                     -- SERVICES FPJ Start
               OR (POLL.amount <> POLLA.amount)
               OR (POLL.amount IS NULL AND POLLA.amount IS NOT NULL)
               OR (POLL.amount IS NOT NULL AND POLLA.amount IS NULL)
                     -- SERVICES FPJ Start
               OR (POLL.ship_to_location_id <>
                POLLA.ship_to_location_id)
               OR (POLL.ship_to_location_id IS NULL
                AND POLLA.ship_to_location_id IS NOT NULL)
               OR (POLL.ship_to_location_id IS NOT NULL
                AND POLLA.ship_to_location_id IS NULL)
               OR (POLL.need_by_date <> POLLA.need_by_date)
               OR (POLL.need_by_date IS NULL
                AND POLLA.need_by_date IS NOT NULL)
               OR (POLL.need_by_date IS NOT NULL
                AND POLLA.need_by_date IS NULL)
               OR (POLL.promised_date <> POLLA.promised_date)
               OR (POLL.promised_date IS NULL
                AND POLLA.promised_date IS NOT NULL)
               OR (POLL.promised_date IS NOT NULL
                AND POLLA.promised_date IS NULL)
               OR (POLL.last_accept_date <> POLLA.last_accept_date)
               OR (POLL.last_accept_date IS NULL
                AND POLLA.last_accept_date IS NOT NULL)
               OR (POLL.last_accept_date IS NOT NULL
                AND POLLA.last_accept_date IS NULL)
               OR (POLL.price_override <> POLLA.price_override)
               OR (POLL.price_override IS NULL
                AND POLLA.price_override IS NOT NULL)
               OR (POLL.price_override IS NOT NULL
                AND POLLA.price_override IS NULL)  --BUG7286203 REMOVED THE CHECK FOR TAXCODE ID
               -- <Complex Work R12 Start>
               OR (POLL.payment_type <> POLLA.payment_type)
               OR (POLL.payment_type IS NULL
                AND POLLA.payment_type IS NOT NULL)
               OR (POLL.payment_type IS NOT NULL
                AND POLLA.payment_type IS NULL)
               OR (POLL.description <> POLLA.description)
               OR (POLL.description IS NULL
                AND POLLA.description IS NOT NULL)
               OR (POLL.description IS NOT NULL
                AND POLLA.description IS NULL)
               OR (POLL.work_approver_id <> POLLA.work_approver_id)
               OR (POLL.work_approver_id IS NULL
                AND POLLA.work_approver_id IS NOT NULL)
               OR (POLL.work_approver_id IS NOT NULL
                AND POLLA.work_approver_id IS NULL)
               -- <Complex Work R12 End>
               OR (POLL.shipment_num <> POLLA.shipment_num)
               OR (POLL.shipment_num IS NULL
                AND POLLA.shipment_num IS NOT NULL)
               OR (POLL.shipment_num IS NOT NULL
                AND POLLA.shipment_num IS NULL)
               OR (POLL.sales_order_update_date <> POLLA.sales_order_update_date)
               OR (POLL.sales_order_update_date IS NULL
                AND POLLA.sales_order_update_date IS NOT NULL)
               OR (POLL.sales_order_update_date IS NOT NULL
                AND POLLA.sales_order_update_date IS NULL)
               OR (p_chk_cancel_flag = 'Y' AND --<CancelPO FPJ>
                  ((POLL.cancel_flag <> POLLA.cancel_flag)
            OR (POLL.cancel_flag IS NULL
                 AND POLLA.cancel_flag IS NOT NULL)
            OR (POLL.cancel_flag IS NOT NULL
                AND POLLA.cancel_flag IS NULL)))));

        elsif (p_element = 'PORCH_PBREAK') then  --p_element='PORCH_HEADER'*/
        /*
        ** note that change sin price discount will be reflected in
        ** changes in price_override, hence price_discount is not
        ** considered below.
        ** Also changes to ship_to_org will not cause a revision change.
        ** since print changed orders report does not cover that case.
        */
            Select 'Y'
            INTO   x_different
            from sys.dual
            where exists(
            select null
               FROM  PO_LINE_LOCATIONS POLL,
                 PO_LINE_LOCATIONS_ARCHIVE POLLA
               WHERE POLL.po_header_id = p_doc_id
               AND  POLL.po_release_id is null    -- Bug 3876235
               AND (p_line_id IS NULL OR POLL.po_line_id = p_line_id) --<CancelPO FPJ>
               AND (p_line_location_id IS NULL OR POLL.line_location_id = p_line_location_id) --<CancelPO FPJ>
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
               (POLLA.line_location_id is NULL)
               OR (POLL.quantity <> POLLA.quantity)
               OR (POLL.quantity IS NULL AND POLLA.quantity IS NOT NULL)
               OR (POLL.quantity IS NOT NULL AND POLLA.quantity IS NULL)
               OR (POLL.ship_to_location_id <>
                POLLA.ship_to_location_id)
               OR (POLL.ship_to_location_id IS NULL
                AND POLLA.ship_to_location_id IS NOT NULL)
               OR (POLL.ship_to_location_id IS NOT NULL
                AND POLLA.ship_to_location_id IS NULL)
               OR (POLL.price_override <> POLLA.price_override)
               OR (POLL.price_override IS NULL
                AND POLLA.price_override IS NOT NULL)
               OR (POLL.price_override IS NOT NULL
                AND POLLA.price_override IS NULL)
               OR (POLL.shipment_num <> POLLA.shipment_num)
               OR (POLL.shipment_num IS NULL
                AND POLLA.shipment_num IS NOT NULL)
               OR (POLL.shipment_num IS NOT NULL
                AND POLLA.shipment_num IS NULL)
                       /* <TIMEPHASED FPI START> */
                       OR (POLL.start_date <> POLLA.start_date)
                       OR (POLL.start_date is null AND POLLA.start_date is not null)
                       OR (POLL.start_date is not null AND POLLA.start_date is null)
                       OR (POLL.end_date <> POLLA.end_date)
                       OR (POLL.end_date is null AND POLLA.end_date is not null)
                       OR (POLL.end_date is not null AND POLLA.end_date is null)));
                       /* <TIMEPHASED FPI END> */

              -- SERVICES FPJ Start
              -- Comparison for the Price differentials entity

                 ELSIF (p_element = 'PORCH_LINE_PRICE_DIFF')  THEN

                 --SQL What: Check latest external archived records with
                 --  the current records
                 --SQL Why: If certain columns are different, a new
                 --  revision is needed

                 SELECT 'Y'
                   INTO x_different
                   FROM po_price_differentials pdf,
                        po_price_differentials_archive pdfa,
                        po_lines_all pol
                  WHERE pol.po_header_id = p_doc_id
                    AND pol.po_line_id = pdf.entity_id
                    AND pdf.entity_type in ('PO LINE', 'BLANKET LINE')
                    AND pdf.price_differential_id = pdfa.price_differential_id (+)
                    AND pdfa.latest_external_flag (+) = 'Y'
                    AND (
                            ( pdfa.price_differential_id IS NULL )
                        OR  ( pdf.price_differential_num <> pdfa.price_differential_num )
                        OR  ( pdf.price_type <> pdfa.price_type )
                        OR  (   ( pdf.multiplier <> pdfa.multiplier )
                            OR  ( pdf.multiplier IS NULL AND pdfa.multiplier IS NOT NULL )
                            OR  ( pdf.multiplier IS NOT NULL AND pdfa.multiplier IS NULL ) )
                        OR  (   ( pdf.max_multiplier <> pdfa.max_multiplier )
                            OR  ( pdf.max_multiplier IS NULL AND pdfa.max_multiplier IS NOT NULL )
                            OR  ( pdf.max_multiplier IS NOT NULL AND pdfa.max_multiplier IS NULL ) )
                        OR  (   ( pdf.min_multiplier <> pdfa.min_multiplier)
                            OR  ( pdf.min_multiplier IS NULL AND pdfa.min_multiplier IS NOT NULL )
                            OR  ( pdf.min_multiplier IS NOT NULL AND pdfa.min_multiplier IS NULL ) )
                        OR  (   ( pdf.enabled_flag <> pdfa.enabled_flag )
                            OR  ( pdf.enabled_flag IS NULL AND pdfa.enabled_flag IS NOT NULL )
                            OR  ( pdf.enabled_flag IS NOT NULL AND pdfa.enabled_flag IS NULL ) )
                        );

                 ELSIF (p_element = 'PORCH_PB_PRICE_DIFF')  THEN

                 --SQL What: Check latest external archived records with
                 --  the current records
                 --SQL Why: If certain columns are different, a new
                 --  revision is needed

                 SELECT 'Y'
                   INTO x_different
                   FROM po_price_differentials pdf,
                        po_price_differentials_archive pdfa,
                        po_line_locations_all poll
                  WHERE poll.po_header_id = p_doc_id
                    AND poll.line_location_id = pdf.entity_id
                    AND pdf.entity_type = 'PRICE BREAK'
                    AND pdf.price_differential_id = pdfa.price_differential_id (+)
                    AND pdfa.latest_external_flag (+) = 'Y'
                    AND (
                            ( pdfa.price_differential_id IS NULL )
                        OR  ( pdf.price_differential_num <> pdfa.price_differential_num )
                        OR  ( pdf.price_type <> pdfa.price_type )
                        OR  (   ( pdf.multiplier <> pdfa.multiplier )
                            OR  ( pdf.multiplier IS NULL AND pdfa.multiplier IS NOT NULL )
                            OR  ( pdf.multiplier IS NOT NULL AND pdfa.multiplier IS NULL ) )
                        OR  (   ( pdf.max_multiplier <> pdfa.max_multiplier )
                            OR  ( pdf.max_multiplier IS NULL AND pdfa.max_multiplier IS NOT NULL )
                            OR  ( pdf.max_multiplier IS NOT NULL AND pdfa.max_multiplier IS NULL ) )
                        OR  (   ( pdf.min_multiplier <> pdfa.min_multiplier)
                            OR  ( pdf.min_multiplier IS NULL AND pdfa.min_multiplier IS NOT NULL )
                            OR  ( pdf.min_multiplier IS NOT NULL AND pdfa.min_multiplier IS NULL ) )
                        OR  (   ( pdf.enabled_flag <> pdfa.enabled_flag )
                            OR  ( pdf.enabled_flag IS NULL AND pdfa.enabled_flag IS NOT NULL )
                            OR  ( pdf.enabled_flag IS NOT NULL AND pdfa.enabled_flag IS NULL ) )
                        );

                -- SERVICES FPJ End

        elsif (p_element = 'PORCH_DISTRIBUTIONS') then  --p_element='PORCH_HEADER'*/
            /*Bug 13960467:While comparing Encumbered_Flag, ensure that the shipment
            is not 'Finally Closed' since Encumbered_Flag would change to 'N' in the
            base tables and remain the same in the archive tables when a shipment is
            finally closed, thereby causing a mis-match during comparision*/
            Select 'Y'
            INTO   x_different
            from sys.dual
            where exists(
            select null
               FROM  PO_DISTRIBUTIONS POD,
                 PO_DISTRIBUTIONS_ARCHIVE PODA,
		 PO_LINE_LOCATIONS POLL --Bug 13960467
               WHERE POD.po_header_id = p_doc_id
               AND (POD.line_location_id = POLL.line_location_id) --Bug 13960467
               AND (p_line_id IS NULL OR POD.po_line_id = p_line_id) --<CancelPO FPJ>
               AND (p_line_location_id IS NULL OR POD.line_location_id = p_line_location_id) --<CancelPO FPJ>
               AND   POD.po_distribution_id =
                PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y'
               AND (
               (PODA.po_distribution_id is NULL)
            OR (POD.quantity_ordered <> PODA.quantity_ordered)
            OR (POD.quantity_ordered IS NULL
                AND PODA.quantity_ordered IS NOT NULL)
            OR (POD.quantity_ordered IS NOT NULL
                AND PODA.quantity_ordered IS NULL)
                     -- SERVICES FPJ
            OR (POD.amount_ordered <> PODA.amount_ordered)
            OR (POD.amount_ordered IS NULL
                AND PODA.amount_ordered IS NOT NULL)
            OR (POD.amount_ordered IS NOT NULL
                AND PODA.amount_ordered IS NULL)
                     -- SERVICES FPJ
	    -- Bug18386390 revert code fix in 12529922
               OR (POD.deliver_to_person_id <>
                   PODA.deliver_to_person_id)
               OR (POD.deliver_to_person_id IS NULL
                   AND PODA.deliver_to_person_id IS NOT NULL)
               OR (POD.deliver_to_person_id IS NOT NULL
                   AND PODA.deliver_to_person_id IS NULL)
               /* OR (POD.distribution_num <> PODA.distribution_num)*/

            -- BUG 9766489: Since The Document is allowed to be canceled when its in requires
   -- Reapproval state, But if the document is unreserved and have the backing
   -- document then its not possible to manage the cancel action on the Main Document.
   -- Disabling the cancel action on requires reapproval action when document is
   -- unreserved.
   OR (p_chk_cancel_flag  = 'N'
       AND NVL(POLL.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED' --Bug 13960467
       AND POD.BUDGET_ACCOUNT_ID IS NOT NULL
       AND Nvl(POD.ENCUMBERED_FLAG,'P') <> Nvl(PODA.ENCUMBERED_FLAG,'P')
       -- to handle the null encumbered_flag
       )
               ));--Bug7286203 REMOVED THE CHECK FOR RECOVERY_RATE


        end if; -- type = PORCH_PO and p_element = 'PORCH_HEADER'*/

    elsif (p_type = 'PORCH_RELEASE') then -- (type = 'PORCH_PO')*/

            l_progress := '030';
        if (p_element = 'PORCH_HEADER') then

/* Start Bug# 6066670, continuation of Bug# 5943064.
 	    We need to consider 3 cases. I Supplier portal
 	    if the PO is 'Accepted'/'Rejected'  then we set the acceptance_required_flag
 	    to 'N' so that we dont Enter any more acceptances.the accepted_flag can be 'Y'/'N'.
 	    But when creating the document revision we were not considering that
 	    accepted_flag can be 'N' when rejected and we should cause a document revision
 	    when this change happens and these documents can be cancelled.
 	    So we are now checking if the document is both Accepted and Rejected cases and
 	    since normal Accetances also have 'N' we differentiate a 'Rejected' case
 	    by also looking at the acceptance_required_flag in the po_headers table.
 	    Doing the same for the acceptance_due_date. l_accepted_flag='X' will
 	    represent lines which dont have acceptance Entered.
 	    We only have 'Y' and 'N' for acceptance_required_flag in Releases.
 	    so we dont need to check the other conditions as for PO.*/

          -- Bug 3388218 Start
            Begin
                 Select pav.accepted_flag
                into l_accepted_flag
                from po_acceptances_v pav,
                     po_releases por
                where por.po_release_id=p_doc_id
                and por.po_release_id=pav.po_release_id
                and pav.revision_num= por.revision_num
                and por.acceptance_required_flag='N'
                and rownum=1;
                --and pav.accepted_flag='Y';
            Exception
                when others then
                     l_accepted_flag:='X';
            End;
           -- Bug 3388218 End

 /*Bug5154626: cancel action on the releases in approved state errors
      out on which Mass update buyer program is run to update buyer name.
   Hence donot use the agent_id comparision for cancel flow*/

            Select 'Y'
            INTO   x_different
            from sys.dual
            where exists(
            select null
               FROM   PO_RELEASES POR,
                  PO_RELEASES_ARCHIVE PORA
               WHERE  POR.po_release_id = p_doc_id
               AND    POR.po_release_id = PORA.po_release_id
               AND    PORA.latest_external_flag (+) = 'Y'
               AND    (
               (PORA.po_release_id IS NULL)
            OR (POR.release_num <> PORA.release_num)
            OR((POR.agent_id <> PORA.agent_id) AND  (p_chk_cancel_flag='Y'))
            OR (POR.release_date <> PORA.release_date)
                        -- <INBOUND LOGISTICS FPJ START>
                        OR (POR.shipping_control <>
                            PORA.shipping_control)
                        OR (POR.shipping_control IS NULL
                            AND PORA.shipping_control IS NOT NULL)
                        OR (POR.shipping_control IS NOT NULL
                            AND PORA.shipping_control IS NULL)
                        -- <INBOUND LOGISTICS FPJ END>
        -- Start Bug 3388218
						OR ((POR.acceptance_required_flag <> PORA.acceptance_required_flag)
						  AND (POR.acceptance_required_flag <> 'N'))
						  OR  (PORA.acceptance_required_flag in ('Y')
						  AND POR.acceptance_required_flag ='N'
						  AND (nvl(l_accepted_flag,'X') not in ('N', 'Y'))) --Bug# 6066670
        -- End Bug 3388218
            OR (POR.acceptance_required_flag IS NULL
                 AND PORA.acceptance_required_flag IS NOT NULL)
            OR (POR.acceptance_required_flag IS NOT NULL
                 AND PORA.acceptance_required_flag IS NULL)
            OR (POR.acceptance_due_date <>
                PORA.acceptance_due_date)
            OR (POR.acceptance_due_date IS NULL
                 AND PORA.acceptance_due_date IS NOT NULL
                 AND nvl(l_accepted_flag,'X') not in ('N','Y')) -- Bug#3498816,Bug#6066670
            OR (POR.acceptance_due_date IS NOT NULL
                 AND PORA.acceptance_due_date IS NULL)));

        elsif(p_element = 'PORCH_SHIPMENTS') then --p_element='PORCH_HEADER'*/
            Select 'Y'
            INTO   x_different
            from sys.dual
            where exists(
            select null
            FROM  PO_LINE_LOCATIONS POLL,
                 PO_LINE_LOCATIONS_ARCHIVE POLLA
            WHERE POLL.po_release_id = p_doc_id
            AND (p_line_location_id IS NULL OR POLL.line_location_id = p_line_location_id) --<CancelPO FPJ>
            AND   POLL.line_location_id = POLLA.line_location_id (+)
            AND   POLLA.latest_external_flag (+) = 'Y'
            AND   (
                (POLLA.line_location_id is NULL)
            OR (POLL.quantity <> POLLA.quantity)
            OR (POLL.quantity IS NULL
                AND POLLA.quantity IS NOT NULL)
            OR (POLL.quantity IS NOT NULL
                AND POLLA.quantity IS NULL)
                     -- SERVICES FPJ Start
                OR (POLL.amount <> POLLA.amount)
                OR (POLL.amount IS NULL AND POLLA.amount IS NOT NULL)
                OR (POLL.amount IS NOT NULL AND POLLA.amount IS NULL)
                     -- SERVICES FPJ Start
            OR (POLL.ship_to_location_id <>
                POLLA.ship_to_location_id)
            OR (POLL.ship_to_location_id IS NULL
                AND POLLA.ship_to_location_id IS NOT NULL)
            OR (POLL.ship_to_location_id IS NOT NULL
                AND POLLA.ship_to_location_id IS NULL)
            OR (POLL.need_by_date <> POLLA.need_by_date)
            OR (POLL.need_by_date IS NULL
                AND POLLA.need_by_date IS NOT NULL)
            OR (POLL.need_by_date IS NOT NULL
                AND POLLA.need_by_date IS NULL)
            OR (POLL.promised_date <> POLLA.promised_date)
            OR (POLL.promised_date IS NULL
                AND POLLA.promised_date IS NOT NULL)
            OR (POLL.promised_date IS NOT NULL
                AND POLLA.promised_date IS NULL)
            OR (POLL.last_accept_date <> POLLA.last_accept_date)
            OR (POLL.last_accept_date IS NULL
                AND POLLA.last_accept_date IS NOT NULL)
            OR (POLL.last_accept_date IS NOT NULL
                AND POLLA.last_accept_date IS NULL)
            OR (POLL.price_override <> POLLA.price_override)
            OR (POLL.price_override IS NULL
                AND POLLA.price_override IS NOT NULL)
            OR (POLL.price_override IS NOT NULL
                AND POLLA.price_override IS NULL)  --BUG7286203 REMOVED THE CHECK FOR TAXCODE ID
            OR (POLL.shipment_num <> POLLA.shipment_num)
            OR (POLL.shipment_num IS NULL
                AND POLLA.shipment_num IS NOT NULL)
            OR (POLL.shipment_num IS NOT NULL
                AND POLLA.shipment_num IS NULL)
               OR (POLL.sales_order_update_date <> POLLA.sales_order_update_date)
               OR (POLL.sales_order_update_date IS NULL
                AND POLLA.sales_order_update_date IS NOT NULL)
               OR (POLL.sales_order_update_date IS NOT NULL
                AND POLLA.sales_order_update_date IS NULL)
            OR (p_chk_cancel_flag = 'Y' AND --<CancelPO FPJ>
               ((POLL.cancel_flag <> POLLA.cancel_flag)
            OR (POLL.cancel_flag IS NULL
                 AND POLLA.cancel_flag IS NOT NULL)
            OR (POLL.cancel_flag IS NOT NULL
                AND POLLA.cancel_flag IS NULL)))));

        elsif (p_element = 'PORCH_DISTRIBUTIONS') then  --p_element='PORCH_HEADER'*/
            Select 'Y'
            INTO   x_different
            from sys.dual
            where exists(
            select null
               FROM  PO_DISTRIBUTIONS POD,
                 PO_DISTRIBUTIONS_ARCHIVE PODA
               WHERE POD.po_release_id = p_doc_id
               AND (p_line_location_id IS NULL OR POD.line_location_id = p_line_location_id) --<CancelPO FPJ>
               AND   POD.po_distribution_id =
                PODA.po_distribution_id (+)
               AND   PODA.latest_external_flag (+) = 'Y'
               AND (
                (PODA.po_distribution_id is NULL)
               OR (POD.quantity_ordered <> PODA.quantity_ordered)
               OR (POD.quantity_ordered IS NULL
                       AND PODA.quantity_ordered IS NOT NULL)
               OR (POD.quantity_ordered IS NOT NULL
                   AND PODA.quantity_ordered IS NULL)
                     -- SERVICES FPJ
            OR (POD.amount_ordered <> PODA.amount_ordered)
            OR (POD.amount_ordered IS NULL
                AND PODA.amount_ordered IS NOT NULL)
            OR (POD.amount_ordered IS NOT NULL
                AND PODA.amount_ordered IS NULL)
                     -- SERVICES FPJ
	       -- Bug18386390 revert code fix in 12529922
	       OR (POD.deliver_to_person_id <>
                   PODA.deliver_to_person_id)
               OR (POD.deliver_to_person_id IS NULL
                   AND PODA.deliver_to_person_id IS NOT NULL)
               OR (POD.deliver_to_person_id IS NOT NULL
                   AND PODA.deliver_to_person_id IS NULL)
             /*  OR (POD.distribution_num <> PODA.distribution_num) */

          -- BUG: 9766489 Since The Document is allowed to be canceled when its in requires
   -- Reapproval state, But if the document is unreserved and have the backing
   -- document then its not possible to manage the cancel action on the Main Document.
   -- Disabling the cancel action on requires reapproval action when document is
   -- unreserved.
   OR (p_chk_cancel_flag  = 'N'
       AND POD.BUDGET_ACCOUNT_ID IS NOT NULL
       AND Nvl(POD.ENCUMBERED_FLAG,'P') <> Nvl(PODA.ENCUMBERED_FLAG,'P')
       -- to handle the null encumbered_flag
      )
                  ));--Bug7286203 REMOVED THE CHECK FOR RECOVERY_RATE


        end if; -- p_type = PORCH_RELEASE and p_element = 'PORCH_HEADER'*/
    end if; -- p_type = 'PORCH_PO'*/

EXCEPTION
when no_data_found then
x_different := 'N'; /* This is not really an error */
when others then
PO_MESSAGE_S.SQL_ERROR(routine => 'Compare_Table',
                             location => l_progress,
                             error_code => SQLCODE);

END Compare_Table;

--<CancelPO FPJ Start>
-------------------------------------------------------------------------------
--Start of Comments
--Name: Compare
--Function:
--  Checks if a PO/PA/Release Header/Line/Shipment are different compared to
--  its archived copy. The output parameter x_different indicates if they are different.
--  All attributes that cause revision change except cancel_flag/closed_code are compared
--Parameters:
--IN:
--p_api_version
--  Standard API Version
--p_doc_id
--  The Document ID of the PO/PA/Release
--p_doc_type
--  The Document Type indicating PO, PA, or RELEASE
--p_doc_subtype
--  The Document Subtype
--p_line_id
--  The Line ID if the Line/Shipment needs to be compared
--p_line_location_id
--  The Shipment ID if the Shipment needs to be compared
--OUT:
--x_different
--  Indicates if the entity Header/Line/Shipment is different.
--  One of the Following Values is returned:
--    Y If Archival exists and differences exist
--    N If Archival exists and no differences exist
--    M If archival record is missing.
--x_return_status
--  Standard API Return Status S, U, E
--Testing:
--  Test for all Types of Documents and Entity Levels
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Compare(
    p_api_version        IN NUMBER,
    p_doc_id             IN NUMBER,
    p_doc_type           IN VARCHAR2,
    p_doc_subtype        IN VARCHAR2,
    p_line_id            IN NUMBER,
    p_line_location_id   IN NUMBER,
    x_different          OUT NOCOPY Varchar2,
    x_return_status      OUT NOCOPY VARCHAR2
) IS

l_api_name    CONSTANT VARCHAR(30) := 'COMPARE';
l_api_version CONSTANT NUMBER := 1.0;
l_progress    VARCHAR2(3) := '000';
l_need_new_revision boolean := FALSE;
l_Archive_Record_Exists VARCHAR2(1);

BEGIN

IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name||'.'
          || l_progress, 'Entering Procedure '||l_api_name || ' DocType:' || p_doc_type
          || ' DocId:' || p_doc_id|| ' LineId:' || p_line_id
          || ' LineLocId:' || p_line_location_id);
    END IF;
END IF;

l_progress := '010';
--Standard call to check for call compatibility
IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    if ((p_doc_type = 'PO') OR (p_doc_type = 'PA')) THEN

        l_progress := '015';
        BEGIN
            select 'Y'
            into l_Archive_Record_Exists
            from po_headers_archive
            where po_header_id = p_doc_id and rownum = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_Archive_Record_Exists := 'N';
        END;

        IF l_Archive_Record_Exists = 'N' THEN
            x_different := 'M'; --Return M If archival record is missing.

            IF g_fnd_debug = 'Y' THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                  FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name||'.'
                  || l_progress, 'x_different=M, No Archived Record Exists');
                END IF;
            END IF;

            return;
        END IF;

        l_progress := '020';
        IF p_line_id is null THEN -- Compare Header If not at line level
            l_need_new_revision :=
                Check_PO_PA_Revision(
                    p_doc_type         => p_doc_type,
                    p_doc_subtype      => p_doc_subtype,
                    p_doc_id           => p_doc_id,
                    p_table_name       => 'HEADER',
                    p_line_id          => p_line_id,
                    p_line_location_id => p_line_location_id,
                    p_chk_cancel_flag  => 'N',
                    x_different        => x_different);

            IF x_different = 'Y' THEN

                IF g_fnd_debug = 'Y' THEN
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name||'.'
                      || l_progress, 'PO Header is Different');
                    END IF;
                END IF;

                return;
            END IF;
        END IF;

        l_progress := '030';
        IF p_line_location_id is null THEN -- Compare Line If not at Shipment level
            l_need_new_revision :=
                Check_PO_PA_Revision(
                    p_doc_type         => p_doc_type,
                    p_doc_subtype      => p_doc_subtype,
                    p_doc_id           => p_doc_id,
                    p_table_name       => 'LINES',
                    p_line_id          => p_line_id,
                    p_line_location_id => p_line_location_id,
                    p_chk_cancel_flag  => 'N',
                    x_different        => x_different);

            IF x_different = 'Y' THEN

                IF g_fnd_debug = 'Y' THEN
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name||'.'
                      || l_progress, 'PO Line is Different');
                    END IF;
                END IF;

                return;
            END IF;
        END IF;

        l_progress := '040';
        -- Compare Shipments for any level: Header/Line/Shipment
        l_need_new_revision :=
            Check_PO_PA_Revision(
                p_doc_type         => p_doc_type,
                p_doc_subtype      => p_doc_subtype,
                p_doc_id           => p_doc_id,
                p_table_name       => 'SHIPMENTS',
                p_line_id          => p_line_id,
                p_line_location_id => p_line_location_id,
                p_chk_cancel_flag  => 'N',
                x_different        => x_different);

        IF x_different = 'Y' THEN

            IF g_fnd_debug = 'Y' THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                  FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name||'.'
                  || l_progress, 'PO Shipment is Different');
                END IF;
            END IF;

            return;
        END IF;

        l_progress := '050';
        -- Compare Distributions for any level: Header/Line/Shipment
        l_need_new_revision :=
            Check_PO_PA_Revision(
                p_doc_type         => p_doc_type,
                p_doc_subtype      => p_doc_subtype,
                p_doc_id           => p_doc_id,
                p_table_name       => 'DISTRIBUTIONS',
                p_line_id          => p_line_id,
                p_line_location_id => p_line_location_id,
                p_chk_cancel_flag  => 'N',
                x_different        => x_different);

    elsif ((p_doc_type = 'RELEASE')) THEN

        l_progress := '055';
        BEGIN
            select 'Y'
            into l_Archive_Record_Exists
            from po_releases_archive
            where po_release_id = p_doc_id and rownum = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_Archive_Record_Exists := 'N';
        END;

        IF l_Archive_Record_Exists = 'N' THEN
            x_different := 'N';

            IF g_fnd_debug = 'Y' THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                  FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name||'.'
                  || l_progress, 'No Archived Record Exists');
                END IF;
            END IF;

            return;
        END IF;

        l_progress := '060';
        IF p_line_location_id is null THEN -- Compare Header If not at Shipment level
            l_need_new_revision :=
                Check_Release_Revision(
                    p_doc_type         => p_doc_type,
                    p_doc_subtype      => p_doc_subtype,
                    p_doc_id           => p_doc_id,
                    p_table_name       => 'HEADER',
                    p_line_location_id => p_line_location_id,
                    p_chk_cancel_flag  => 'N',
                    x_different        => x_different);

            IF x_different = 'Y' THEN

                IF g_fnd_debug = 'Y' THEN
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name||'.'
                      || l_progress, 'Release Header is Different');
                    END IF;
                END IF;

                return;
            END IF;
        END IF;

        l_progress := '070';
        -- Compare Shipments for any level: Release Header/Shipment
        l_need_new_revision :=
            Check_Release_Revision(
                p_doc_type         => p_doc_type,
                p_doc_subtype      => p_doc_subtype,
                p_doc_id           => p_doc_id,
                p_table_name       => 'SHIPMENTS',
                p_line_location_id => p_line_location_id,
                p_chk_cancel_flag  => 'N',
                x_different        => x_different);

        IF x_different = 'Y' THEN

            IF g_fnd_debug = 'Y' THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                  FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name||'.'
                  || l_progress, 'Releqase Shipment is Different');
                END IF;
            END IF;

            return;
        END IF;

        l_progress := '080';
        -- Compare Distributions for any level: Release Header/Shipment
        l_need_new_revision :=
            Check_Release_Revision(
                p_doc_type         => p_doc_type,
                p_doc_subtype      => p_doc_subtype,
                p_doc_id           => p_doc_id,
                p_table_name       => 'DISTRIBUTIONS',
                p_line_location_id => p_line_location_id,
                p_chk_cancel_flag  => 'N',
                x_different        => x_different);

    else
      x_different := 'N';
    end if;  /* (p_doc_type = 'PO') OR (p_doc_type = 'PA') */

    IF g_fnd_debug = 'Y' THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name||'.'
          || l_progress, 'Final x_Different ' || x_different);
        END IF;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);

END Compare;

-------------------------------------------------------------------------------
--<Bug 14207546 :Cancel Refactoring Project >
--Start of Comments
--Name: CHECK_REV_DIFF
--Function:
--   Checks if there are any non-approved changes in the base tables
--  The below columns of base tables are compared against archive :
--  Need_By_Data /Promised Date
--  Quantity
--  Price
--  Amount

--Parameters:
--IN:
--p_api_version
--  Standard API Version
--p_doc_id
--  The Document ID of the PO/PA/Release
--p_doc_type
--  The Document Type indicating PO, PA, or RELEASE
--p_doc_subtype
--  The Document Subtype
--p_line_id
--  The Line ID if the Line/Shipment needs to be compared
--p_line_location_id
--  The Shipment ID if the Shipment needs to be compared
--p_action_level
--  The control action level i.e. HEADER/LINE/LINE_LOCATION
--OUT:
--x_msg
-- This will have value if the entity is different than its previous revision
-- based on above explained check.
--x_return_status
--  Standard API Return Status S, U, E
--Testing:
--  Test for all Types of Documents and Entity Levels
--End of Comments
-------------------------------------------------------------------------------


PROCEDURE CHECK_REV_DIFF(
    p_api_version        IN NUMBER,
    p_doc_id             IN NUMBER,
    p_doc_type           IN VARCHAR2,
    p_doc_subtype        IN VARCHAR2,
    p_line_id            IN NUMBER,
    p_line_location_id   IN NUMBER,
    p_action_level       IN VARCHAR2,
    x_msg_name           OUT NOCOPY VARCHAR2,
    x_msg_type           OUT NOCOPY VARCHAR2,
    x_token_name_tbl     OUT NOCOPY PO_TBL_VARCHAR30,
    x_token_value_tbl    OUT NOCOPY PO_TBL_VARCHAR2000,
    x_return_status      OUT NOCOPY VARCHAR2
)
  IS

    l_api_name    CONSTANT VARCHAR(30) := 'CHECK_REV_DIFF';
    l_api_version CONSTANT NUMBER := 1.0;
    l_progress    VARCHAR2(3) := '000';
    d_module   CONSTANT VARCHAR2(100) := G_PKG_NAME||l_api_name;
    d_debug_stmt BOOLEAN :=(g_fnd_debug = 'Y')
                           AND (FND_LOG.G_CURRENT_RUNTIME_LEVEL
                                <= FND_LOG.LEVEL_STATEMENT) ;


    -- Bug 17318886:
    -- Russian lang. characters would be multibyte unlike English alphabets
    -- which are single byte characters.
    -- This variable requires NVARCHAR declaration to handle multibyte languages
    l_line_token NVARCHAR2(20);
    l_ship_token NVARCHAR2(20);
    l_amt_token NVARCHAR2(20);
    l_qty_token NVARCHAR2(20);
    l_doc_token  NVARCHAR2(20);
    l_to_token  NVARCHAR2(20);
    l_no_chg_token NVARCHAR2(20);
    l_po_encumbrance_flag FINANCIALS_SYSTEM_PARAMETERS.purch_encumbrance_flag%TYPE;


  BEGIN

    IF d_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_subtype', p_doc_subtype);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_id', p_doc_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_type', p_doc_type);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_line_id', p_line_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_line_location_id', p_line_location_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_action_level', p_action_level);
    END IF;



    l_line_token   := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
    l_ship_token   := fnd_message.get_string('PO', 'PO_ZMVOR_SHIPMENT');
    l_amt_token    := fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT');
    l_qty_token    := fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY');
    l_doc_token    := fnd_message.get_string('PO', 'PO_DOCUMENT_LABEL');
    l_to_token     := fnd_message.get_string('PO', 'PO_WF_NOTIF_TO');
    l_no_chg_token := fnd_message.get_string('PO', 'PO_DIALOG_NO_LABEL')||' '||fnd_message.get_string('PO','PO_WF_NOTIF_CHANGE');

     x_token_name_tbl := PO_TBL_VARCHAR30();
     x_token_name_tbl.EXTEND(5);
     x_token_value_tbl := PO_TBL_VARCHAR2000();
     x_token_value_tbl.EXTEND(5);


    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_name:=NULL;

    BEGIN

    -- <13503748: Edit without unreserve ER >
    -- Throw an error if the encumbered flag at PO distributions is N for
    -- encumbered enabled environment else give warning

     --Query encumbrance flags from FINANCIALS_SYSTEM_PARAMS
     --Using this flag to stop revert changes as part of cancel when encumbrance
     --is on and any of the encumbrance related attribute is changed.
     -- This check would be needed until the Encumbrance ER is in place.
      SELECT NVL(fsp.purch_encumbrance_flag, 'N')
      INTO   l_po_encumbrance_flag
      FROM   financials_system_params_all fsp
      WHERE  org_id = (SELECT org_id
                       FROM po_releases_all
                       WHERE po_release_id = p_doc_id
                             AND p_doc_type = PO_DOCUMENT_CANCEL_PVT.c_doc_type_RELEASE
                       UNION ALL
                       SELECT org_id
                       FROM po_headers_all
                       WHERE po_header_id = p_doc_id
                             AND p_doc_type <> PO_DOCUMENT_CANCEL_PVT.c_doc_type_RELEASE);





      l_progress :='001';

      SELECT 'PO_CHANGED_CANT_CANCEL_WARN',
             'DOC_LINE_SHIP_DIST_NUM',
              l_doc_token||''||segment1||','|| l_line_token||pol.LINE_NUM||','||l_ship_token||poll.SHIPMENT_NUM,
              'PRICE_TOKEN',
              Decode(Nvl(poall.price_override,0),Nvl(poll.price_override,0),
                l_no_chg_token,
                (poall.price_override||' '||l_to_token ||' '|| poll.price_override)),
              'AMT_QTY_TOKEN',
               DECODE(poll.amount,NULL,l_qty_token,l_amt_token),
              'QTY_AMT',
               Decode(poll.amount,NULL,
                         Decode(poall.quantity,poll.quantity,
                            l_no_chg_token,
                           (poall.quantity||' '||l_to_token ||' '|| poll.quantity)),
                         Decode(poall.amount,poll.amount,
                           l_no_chg_token,
                           (poall.amount||' '||l_to_token ||' '|| poll.amount))
                            ),
              'NEED_BY_PRM_DATE',
               Decode(poll.promised_date,NULL,
                       Decode(poall.need_by_date,poll.need_by_date,
                         l_no_chg_token,
                         (Nvl(To_Char(poall.need_by_date),'Null')||' '||l_to_token ||' '|| Nvl(To_Char(poll.need_by_date),'Null'))),
                       Decode(poall.promised_date,poll.promised_date,
                         l_no_chg_token,
                         (Nvl(To_Char(poall.promised_date),'Null')||' '||l_to_token ||' '|| Nvl(To_Char(poll.promised_date),'Null'))

                         ) )
      INTO x_msg_name,
           x_token_name_tbl(1),
           x_token_value_tbl(1),
           x_token_name_tbl(2),
           x_token_value_tbl(2),
           x_token_name_tbl(3),
           x_token_value_tbl(3),
           x_token_name_tbl(4),
           x_token_value_tbl(4),
           x_token_name_tbl(5),
           x_token_value_tbl(5)

      FROM
        po_line_locations_archive_all poall,
        po_line_locations_all poll,
        po_headers_all poh,
        po_lines_all pol,
        po_distributions_all pod    ---<BUG :13503748>--
      WHERE
        poll.line_location_id = pod.line_location_id     ---<BUG :13503748>--
        AND poll.po_line_id = pol.po_line_id
        AND poll.po_header_id = pol.po_header_id
        AND Nvl(poll.approved_flag,'N')<>'Y'
        AND poll.line_location_id=poall.line_location_id
        AND poh.po_header_id=poll.po_header_id
        AND poall.latest_external_flag ='Y'
        AND ((l_po_encumbrance_flag = 'Y' AND pod.encumbered_flag = 'Y')
             OR l_po_encumbrance_flag = 'N') ---<BUG :13503748>--
              AND (Nvl(poll.price_override,0) <> Nvl(poall.price_override,0)
                   OR Nvl(poll.quantity,0) <> Nvl(poall.quantity,0)
                   OR Nvl(poll.amount,0) <> Nvl(poall.amount,0)
                   OR Nvl(poll.promised_date,sysdate) <> Nvl(poall.promised_date,sysdate)
                   OR Nvl(poll.need_by_date,sysdate) <> Nvl(poall.need_by_date,sysdate))
        AND poll.line_location_id IN
            ( SELECT line_location_id
              FROM   po_line_locations_all
              WHERE  line_location_id = p_line_location_id
                    AND  p_action_level = PO_DOCUMENT_CANCEL_PVT.c_entity_level_SHIPMENT
                     AND 0= (SELECT Count(1)
                             FROM  po_distributions_all pod
                             WHERE pod.line_location_id=p_line_location_id
                                    AND NOT EXISTS (SELECT  po_distribution_id
                                                    FROM    po_distributions_archive_all poad
                                                     WHERE  pod.po_distribution_id=poad.po_distribution_id))
            UNION ALL
              SELECT line_location_id
              FROM   po_line_locations_all
              WHERE  po_line_id = p_line_id
                     AND p_action_level = PO_DOCUMENT_CANCEL_PVT.c_entity_level_LINE
                     AND 0= (SELECT Count(1)
                             FROM  po_line_locations_all poll
                             WHERE po_line_id=p_line_id
                                    AND NOT EXISTS (SELECT line_location_id
                                                    FROM   po_line_locations_archive_all poall
                                                     WHERE  poll.line_location_id=poall.line_location_id))
                     AND 0= (SELECT Count(1)
                             FROM  po_distributions_all pod
                             WHERE pod.po_line_id=p_line_id
                                    AND NOT EXISTS (SELECT  po_distribution_id
                                                    FROM    po_distributions_archive_all poad
                                                     WHERE  pod.po_distribution_id=poad.po_distribution_id))


            UNION ALL
              SELECT line_location_id
              FROM   po_line_locations_all
              WHERE  po_header_id = p_doc_id
                     AND p_doc_type <> PO_DOCUMENT_CANCEL_PVT.c_doc_type_RELEASE
                     AND p_action_level = PO_DOCUMENT_CANCEL_PVT.c_entity_level_HEADER
                     AND 0= (SELECT Count(1)
                             FROM  po_line_locations_all poll
                             WHERE po_header_id = p_doc_id
                                    AND NOT EXISTS (SELECT line_location_id
                                                    FROM   po_line_locations_archive_all poall
                                                    WHERE  poll.line_location_id=poall.line_location_id))
                     AND 0= (SELECT Count(1)
                             FROM  po_distributions_all pod
                             WHERE pod.po_header_id=p_doc_id
                                    AND NOT EXISTS (SELECT  po_distribution_id
                                                    FROM    po_distributions_archive_all poad
                                                     WHERE  pod.po_distribution_id=poad.po_distribution_id))



            UNION ALL
              SELECT line_location_id
              FROM   po_line_locations_all
              WHERE  po_release_id = p_doc_id
                     AND p_doc_type = PO_DOCUMENT_CANCEL_PVT.c_doc_type_RELEASE
                     AND p_action_level = PO_DOCUMENT_CANCEL_PVT.c_entity_level_HEADER
                     AND 0= (SELECT Count(1)
                             FROM  po_line_locations_all poll
                             WHERE po_release_id = p_doc_id
                                    AND NOT EXISTS (SELECT line_location_id
                                                    FROM   po_line_locations_archive_all poall
                                                    WHERE  poll.line_location_id=poall.line_location_id))
                     AND 0= (SELECT Count(1)
                             FROM  po_distributions_all pod
                             WHERE pod.po_release_id=p_doc_id
                                    AND NOT EXISTS (SELECT  po_distribution_id
                                                    FROM    po_distributions_archive_all poad
                                                     WHERE  pod.po_distribution_id=poad.po_distribution_id)));

          x_msg_type :='W';

    IF d_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'x_msg_name', x_msg_name);
    END IF;


    EXCEPTION
      -- If more than one shipment has non approved change
      WHEN Too_Many_Rows THEN
        x_msg_type :='W';
        x_msg_name :='PO_CHANGED_CANT_CAN_MULTI_WARN';

      WHEN No_Data_Found then
        BEGIN

          l_progress :='002';

          -- If the Archive does not exists and the docuemnt is not Approved
          -- Or if the encumbrance is On and any of the enc. related field is modified
          -- then do not allow cancel action , ask user to undo the changes
          SELECT 'PO_CHANGED_CANT_CANCEL'
          INTO  x_msg_name
          FROM  po_line_locations_all poll,
                po_distributions_all pod      ---<BUG :13503748>--
          WHERE poll.line_location_id = pod.line_location_id
                AND (l_po_encumbrance_flag = 'Y' AND pod.encumbered_flag = 'N')
                ---<BUG :13503748>--
                AND Nvl(poll.approved_flag,'N') <>'Y'
                AND ((NOT EXISTS (SELECT  'Archive Exists'
                                 FROM    po_line_locations_archive_all poall
                                 WHERE   poll.line_location_id=poall.line_location_id)
                     OR (0 <> (SELECT Count(1)
                               FROM  po_distributions_all pod
                               WHERE pod.line_location_id=poll.line_location_id
                                     AND NOT EXISTS (SELECT  po_distribution_id
                                FROM    po_distributions_archive_all poad
                                                     WHERE   pod.po_distribution_id=poad.po_distribution_id)
                               )
                        ))

                     OR(l_po_encumbrance_flag = 'Y'
                         AND (EXISTS (SELECT 'Enc Columns Changed'
                                      FROM   po_line_locations_archive_all poall
                                      WHERE  poll.line_location_id=poall.line_location_id
                                             AND poall.latest_external_flag ='Y'
                                             AND (nvl(poll.price_override,0) <> Nvl(poall.price_override,0)
                                                  OR Nvl(poll.quantity,0) <> Nvl(poall.quantity,0)
                                                  OR Nvl(poll.amount,0) <> Nvl(poall.amount,0)))
                              OR EXISTS (SELECT 'Enc Amount Changed'
                                         FROM   po_distributions_all pod,
                                                po_distributions_archive_all poad
                                         WHERE  pod.po_distribution_id=poad.po_distribution_id
                                         AND    pod.line_location_id=poll.line_location_id
                                         AND    poad.latest_external_flag ='Y'
                                         AND    (Nvl(poad.encumbered_amount,0)<>Nvl(pod.encumbered_amount,0)
                                                 OR Nvl(poad.rate,0)<>Nvl(pod.rate,0)
                                                 OR Nvl(poad.quantity_ordered,0)<>Nvl(pod.quantity_ordered,0)
                                                 OR Nvl(poad.amount_ordered,0)<>Nvl(pod.amount_ordered,0)
                                                 OR Nvl(poad.nonrecoverable_tax,0)<>Nvl(pod.nonrecoverable_tax,0))
                                        )
                              )
                       )
                    )
                AND ROWNUM<2
                AND poll.line_location_id IN
                  ( SELECT line_location_id
                    FROM   po_line_locations_all
                    WHERE  line_location_id = p_line_location_id
                          AND  p_action_level = PO_DOCUMENT_CANCEL_PVT.c_entity_level_SHIPMENT
                  UNION ALL
                    SELECT line_location_id
                    FROM   po_line_locations_all
                    WHERE  po_line_id = p_line_id
                          AND p_action_level = PO_DOCUMENT_CANCEL_PVT.c_entity_level_LINE
                  UNION ALL
                    SELECT line_location_id
                    FROM   po_line_locations_all
                    WHERE  po_header_id = p_doc_id
                          AND p_doc_type <> PO_DOCUMENT_CANCEL_PVT.c_doc_type_RELEASE
                          AND p_action_level = PO_DOCUMENT_CANCEL_PVT.c_entity_level_HEADER
                  UNION ALL
                    SELECT line_location_id
                    FROM   po_line_locations_all
                    WHERE  po_release_id = p_doc_id
                          AND p_doc_type = PO_DOCUMENT_CANCEL_PVT.c_doc_type_RELEASE
                          AND p_action_level = PO_DOCUMENT_CANCEL_PVT.c_entity_level_HEADER);
          x_msg_type :='E';

          IF d_debug_stmt THEN
            PO_DEBUG.debug_var(d_module, l_progress, 'x_msg_name', x_msg_name);
          END IF;

        EXCEPTION
          WHEN No_Data_Found THEN
            x_msg_name :=NULL;
            IF d_debug_stmt THEN
             PO_DEBUG.debug_var(d_module, l_progress, 'Setting  x_msg as Null','');
            END IF;

          WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);

        END;

      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);
    END;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
		x_msg_name :=sqlerrm;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_msg_name :=sqlerrm;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		x_msg_name :=sqlerrm;
		FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);

END CHECK_REV_DIFF;



END PO_DOCUMENT_REVISION_GRP;

/
