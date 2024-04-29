--------------------------------------------------------
--  DDL for Package Body ZX_TRL_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TRL_PUB_PKG" AS
/* $Header: zxrwlnrepsrvpubb.pls 120.40 2006/09/22 22:56:08 nipatel ship $ */

  g_current_runtime_level           NUMBER;
  g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
  g_level_error           CONSTANT  NUMBER  := FND_LOG.LEVEL_ERROR;

/* ===========================================================================*
 | PROCEDURE Manage_TaxLines: It will Create, update, delete and cancel tax   |
 |                            lines and summary  tax lines in the tax         |
 |                            repository                                      |
 * ===========================================================================*/

  PROCEDURE Manage_TaxLines
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

    l_error_buffer                 VARCHAR2(100);
    l_msg_context_info_rec         ZX_API_PUB.CONTEXT_INFO_REC_TYPE;

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.BEGIN',
                     'ZX_TRL_PUB_PKG: Manage_TaxLines (+)');
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- bug#4893261- populate message structure
    --
    l_msg_context_info_rec.application_id :=
              p_event_class_rec.application_id;
    l_msg_context_info_rec.entity_code :=
              p_event_class_rec.entity_code;
    l_msg_context_info_rec.event_class_code :=
              p_event_class_rec.event_class_code;
    l_msg_context_info_rec.trx_id :=
              p_event_class_rec.trx_id;
    l_msg_context_info_rec.trx_line_id := NULL;
    l_msg_context_info_rec.trx_level_type := NULL;
    l_msg_context_info_rec.summary_tax_line_number := NULL;
    l_msg_context_info_rec.tax_line_id := NULL;
    l_msg_context_info_rec.trx_line_dist_id := NULL;


    -- p_event_class_rec.TAX_EVENT_TYPE_CODE can be null if there is a transaction with only
    -- header and no lines (e.g. where all tax lines for the document need to be deleted) or
    -- when a transaction in the batch has errors and so the transaction was not selected in
    -- c_lines loop of service types pkg. Hence we should not raise error if the
    -- p_event_class_rec.TAX_EVENT_TYPE_CODE IS NULL.
    /*
    IF p_event_class_rec.TAX_EVENT_TYPE_CODE IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ZX','ZX_TRL_NULL_VALUES');
      ZX_API_PUB.add_msg(l_msg_context_info_rec);
      RETURN;
    END IF;
    */

    -- bug fix 5417887:
    -- g_update_event_process_flag being Y means it is either a single update
    -- document or a update batch process.
    --
    -- during the summary tax line creation, still make use of the
    -- following flags in the p_event_class_rec:
    -- summarization_flag,  retain_summ_tax_line_id_flag
    -- the ASSUMPTION here is:
    -- NO CROSS EVENT_CLASS_CODE DOCUMENTS EXISTS IN THE BATCH!!!
    -- When situation changes in the future, need to revisit the code and make
    -- necessary changes.

    IF ZX_GLOBAL_STRUCTURES_PKG.g_update_event_process_flag = 'Y' THEN

        /*
         * no longer needed for UPDATE case
         *
         * ZX_TRL_MANAGE_TAX_PKG.Update_Synchronize_Taxlines
         *                   (x_return_status => x_return_status);
         *
         */

      ZX_TRL_MANAGE_TAX_PKG.Delete_Detail_Lines
                            (x_return_status   => x_return_status ,
                             p_event_class_rec => p_event_class_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                 'Incorrect return_status after calling ' ||
                 'ZX_TRL_MANAGE_TAX_PKG.Delete_Detail_Lines()');
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                 'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
        END IF;
        RETURN;
      END IF;

      -- for summarization_flag <>'Y', only recreate the detail tax lines
      IF p_event_class_rec.summarization_flag <> 'Y' THEN

        ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines (
            p_event_class_rec => p_event_class_rec,
            x_return_status => x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                   'Incorrect return_status after calling ' ||
                   'ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines()');
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                   'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
          END IF;
          RETURN;
        END IF;

      ELSE --p_event_class_rec.summarization_flag = 'Y'

        -- Preserve old summary_tax_line_id in g_detail_tax_lines_gt (for UPDATE
        -- case) if the same summarization criteria exist in zx_lines_summary
        --
        IF p_event_class_rec.retain_summ_tax_line_id_flag = 'Y' THEN

          ZX_TRL_MANAGE_TAX_PKG.update_exist_summary_line_id (
                            p_event_class_rec => p_event_class_rec,
                            x_return_status   => x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'Incorrect return_status after calling ' ||
                     'ZX_TRL_MANAGE_TAX_PKG.update_exist_summary_line_id()');
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                     'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
            END IF;
            RETURN;
          END IF;
        END IF;

        ZX_TRL_MANAGE_TAX_PKG.Delete_Summary_Lines
                          (x_return_status   => x_return_status,
                           p_event_class_rec => p_event_class_rec);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                   'Incorrect return_status after calling ' ||
                   'ZX_TRL_MANAGE_TAX_PKG.Delete_Summary_Lines()');
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                   'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
          END IF;
          RETURN;
        END IF;

        -- recreate the summary tax lines and detail tax lines

        IF p_event_class_rec.retain_summ_tax_line_id_flag = 'N' THEN

        -- for update tax event, AP will pass in all the trx lines,
        -- that is, all the tax lines will be in the zx_detail_tax_lines_gt.
        -- so if not retain summary_tax_line_id, it is treated same as
        -- created case.

          ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_crt_evnt (
              p_event_class_rec => p_event_class_rec,
              x_return_status   => x_return_status );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'Incorrect return_status after calling ' ||
                     'ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_crt_evnt()');
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                     'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
            END IF;
            RETURN;
          END IF;


          ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines (
              p_event_class_rec => p_event_class_rec,
              x_return_status => x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'Incorrect return_status after calling ' ||
                     'ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines()');
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                     'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
            END IF;
            RETURN;
          END IF;

        ELSE
        -- For retain_summary_tax_line_id ='Y'

          ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines (
              p_event_class_rec => p_event_class_rec,
              x_return_status => x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'Incorrect return_status after calling ' ||
                     'ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines()');
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                     'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
            END IF;
            RETURN;
          END IF;

          ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_upd_evnt (
              p_event_class_rec => p_event_class_rec,
              x_return_status   => x_return_status );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'Incorrect return_status after calling ' ||
                     'ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_crt_evnt()');
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                     'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
            END IF;
            RETURN;
          END IF;

        END IF; -- p_event_class_rec.retain_summ_tax_line_id_flag = 'N'

      END IF; -- p_event_class_rec.summarization_flag <> 'Y'


      ZX_TRL_MANAGE_TAX_PKG.Delete_Loose_Tax_Distributions
                          (x_return_status   => x_return_status,
                           p_event_class_rec => p_event_class_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                 'Incorrect return_status after calling ' ||
                 'ZX_TRL_MANAGE_TAX_PKG.Delete_Loose_Tax_Distributions()');
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                 'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
        END IF;
        RETURN;
      END IF;

    ELSIF (p_event_class_rec.TAX_EVENT_TYPE_CODE = 'CREATE') THEN

      IF p_event_class_rec.summarization_flag = 'Y' THEN

        -- for create tax event, summary tax line created based on
        -- zx_detail_tax_lines_gt, dump detail tax lines from gt to zx_lines
        -- called after summary lines created for performance consideration.
        --
        ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_crt_evnt (
            p_event_class_rec => p_event_class_rec,
            x_return_status   => x_return_status );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                   'Incorrect return_status after calling ' ||
                   'ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_crt_evnt()');
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                   'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
          END IF;
          RETURN;
        END IF;

      END IF;

      -- Dump detail tax lines from gt to zx_lines
      ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines (
        p_event_class_rec => p_event_class_rec,
        x_return_status => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                 'Incorrect return_status after calling ' ||
                 'ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines()');
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                 'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
        END IF;
        RETURN;
      END IF;

    -- bug fix 5417887
    --ELSIF (p_event_class_rec.tax_event_type_code ='UPDATE' OR
    --       p_event_class_rec.tax_event_type_code ='OVERRIDE_TAX' ) THEN
    ELSIF  p_event_class_rec.tax_event_type_code ='OVERRIDE_TAX' THEN

        /*
         * no longer needed for UPDATE case
         *
         * ZX_TRL_MANAGE_TAX_PKG.Update_Synchronize_Taxlines
         *                   (x_return_status => x_return_status);
         *
         */

      ZX_TRL_MANAGE_TAX_PKG.Delete_Detail_Lines
                            (x_return_status   => x_return_status ,
                             p_event_class_rec => p_event_class_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                 'Incorrect return_status after calling ' ||
                 'ZX_TRL_MANAGE_TAX_PKG.Delete_Detail_Lines()');
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                 'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
        END IF;
        RETURN;
      END IF;

      -- for summarization_flag <>'Y', only recreate the detail tax lines
      IF p_event_class_rec.summarization_flag <> 'Y' THEN

        ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines (
            p_event_class_rec => p_event_class_rec,
            x_return_status => x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                   'Incorrect return_status after calling ' ||
                   'ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines()');
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                   'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
          END IF;
          RETURN;
        END IF;

      ELSE --p_event_class_rec.summarization_flag = 'Y'

        -- Preserve old summary_tax_line_id in g_detail_tax_lines_gt (for UPDATE
        -- case) if the same summarization criteria exist in zx_lines_summary
        --
        IF p_event_class_rec.retain_summ_tax_line_id_flag = 'Y' THEN

          ZX_TRL_MANAGE_TAX_PKG.update_exist_summary_line_id (
                            p_event_class_rec => p_event_class_rec,
                            x_return_status   => x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'Incorrect return_status after calling ' ||
                     'ZX_TRL_MANAGE_TAX_PKG.update_exist_summary_line_id()');
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                     'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
            END IF;
            RETURN;
          END IF;
        END IF;

        ZX_TRL_MANAGE_TAX_PKG.Delete_Summary_Lines
                          (x_return_status   => x_return_status,
                           p_event_class_rec => p_event_class_rec);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                   'Incorrect return_status after calling ' ||
                   'ZX_TRL_MANAGE_TAX_PKG.Delete_Summary_Lines()');
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                   'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
          END IF;
          RETURN;
        END IF;

       /* -- commented out for bug fix 5417887
        -- recreate the summary tax lines and detail tax lines

        IF p_event_class_rec.tax_event_type_code = 'UPDATE'
          AND p_event_class_rec.retain_summ_tax_line_id_flag = 'N'
        THEN
        -- for update tax event, AP will pass in all the trx lines,
        -- that is, all the tax lines will be in the zx_detail_tax_lines_gt.
        -- so if not retain summary_tax_line_id, it is treated same as
        -- created case.

          ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_crt_evnt (
              p_event_class_rec => p_event_class_rec,
              x_return_status   => x_return_status );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'Incorrect return_status after calling ' ||
                     'ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_crt_evnt()');
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                     'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
            END IF;
            RETURN;
          END IF;


          ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines (
              p_event_class_rec => p_event_class_rec,
              x_return_status => x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'Incorrect return_status after calling ' ||
                     'ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines()');
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                     'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
            END IF;
            RETURN;
          END IF;

        ELSE
        -- For tax_event_type of UPDATE and retain_summary_tax_line_id ='Y'
        -- or tax_event_type of OVERRIDE_TAX

        -- commented out for bug fix 5417887 end */

          ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines (
              p_event_class_rec => p_event_class_rec,
              x_return_status => x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'Incorrect return_status after calling ' ||
                     'ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines()');
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                     'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
            END IF;
            RETURN;
          END IF;

          ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_upd_evnt (
              p_event_class_rec => p_event_class_rec,
              x_return_status   => x_return_status );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'Incorrect return_status after calling ' ||
                     'ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_crt_evnt()');
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                     'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
            END IF;
            RETURN;
          END IF;

       -- bug fix 5417887
       -- END IF; -- p_event_class_rec.tax_event_type_code = 'UPDATE'

      END IF; -- p_event_class_rec.summarization_flag <> 'Y'


      ZX_TRL_MANAGE_TAX_PKG.Delete_Loose_Tax_Distributions
                          (x_return_status   => x_return_status,
                           p_event_class_rec => p_event_class_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                 'Incorrect return_status after calling ' ||
                 'ZX_TRL_MANAGE_TAX_PKG.Delete_Loose_Tax_Distributions()');
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_error,
                 'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                 'ZX_TRL_PUB_PKG.Manage_TaxLines(-)');
        END IF;
        RETURN;
      END IF;

    END IF;      -- tax_event_type_code

    IF (g_level_procedure >= g_current_runtime_level ) THEN

      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines.END',
                    'ZX_TRL_PUB_PKG: Manage_TaxLines (-)'||x_return_status);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxLines',
                        l_error_buffer);
      END IF;

  END Manage_TaxLines;


/*============================================================================*
 | PROCEDURE Document_Level_Changes: It will Delete / Cancel / Purge tax lines |
 |                                   from the tax repository                   |
 *============================================================================*/

  PROCEDURE Document_Level_Changes
       (x_return_status             OUT NOCOPY VARCHAR2,
        p_event_class_rec        IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
        p_tax_hold_released_code IN     ZX_API_PUB.VALIDATION_STATUS_TBL_TYPE) IS

    l_return_status VARCHAR2(1);

    --TRANSACTION TABLE HAS A NUMBER OF TRANSACTIONS TO BE PROCESSED. BASED ON THE EVENTS ,
    --APPROPRIATE PROCEDURES WOULD BE CALLED. ZX_LINES TABLE MUST HAVE
    --TRANSACTION LINES FOR THE GIVEN TRANSACTION FOR FURTHER PROCESSING.
    l_error_buffer   VARCHAR2(100);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Document_Level_Changes.BEGIN',
                     'ZX_TRL_PUB_PKG: Document_Level_Changes (+)');
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_event_class_rec.TAX_EVENT_TYPE_CODE = 'DELETE') THEN

      ZX_TRL_MANAGE_TAX_PKG.DELETE_TRANSACTION
                        (x_return_status   => l_return_status    ,
                         p_event_class_rec => p_event_class_rec);

    ELSIF (p_event_class_rec.TAX_EVENT_TYPE_CODE = 'PURGE') THEN

      ZX_TRL_MANAGE_TAX_PKG.PURGE_TRANSACTION
                        (x_return_status   => l_return_status,
                         p_event_class_rec => p_event_class_rec);

    ELSIF (p_event_class_rec.TAX_EVENT_TYPE_CODE = 'CANCEL') THEN

      ZX_TRL_MANAGE_TAX_PKG.CANCEL_TRANSACTION
                        (x_return_status   => l_return_status,
                         p_event_class_rec => p_event_class_rec);

    -- begin bug fix 3339364
    ELSIF (p_event_class_rec.TAX_EVENT_TYPE_CODE = 'RELEASE_TAX_HOLD') THEN

      ZX_TRL_MANAGE_TAX_PKG.RELEASE_DOCUMENT_TAX_HOLD
                        (x_return_status   => l_return_status,
                         p_event_class_rec => p_event_class_rec,
                         p_tax_hold_released_code => p_tax_hold_released_code
                         );

    -- end bug fix 3339364
    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Document_Level_Changes.END',
                     'ZX_TRL_PUB_PKG: Document_Level_Changes (-)'||x_return_status);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Document_Level_Changes',
                       'Return Status = ' || x_return_status);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Document_Level_Changes',
                        l_error_buffer);
      END IF;

  END Document_Level_Changes;

/* ===========================================================================*
 | PROCEDURE Synchronize_TaxLines : updates transaction information in the tax|
 |                                  repository                                |
 * ===========================================================================*/

  PROCEDURE Synchronize_TaxLines
       (x_return_status    OUT   NOCOPY VARCHAR2) IS

    l_return_status  VARCHAR2(1);
    l_error_buffer   VARCHAR2(100);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Synchronize_TaxLines.BEGIN',
                     'ZX_TRL_PUB_PKG: Synchronize_TaxLines (+)');
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /****** no longer needed  ***********
     *ZX_TRL_MANAGE_TAX_PKG.Update_Transaction_Info
     *                  (x_return_status    =>  l_return_status);
     *
     *************************************/


    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Synchronize_TaxLines.END',
                     'ZX_TRL_PUB_PKG: Synchronize_TaxLines (-)'||x_return_status);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Synchronize_TaxLines',
                       'Return Status = ' || x_return_status);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Synchronize_TaxLines',
                        l_error_buffer);
      END IF;

  END Synchronize_TaxLines;

/* ===========================================================================*
 | PROCEDURE Mark_Tax_Lines_Delete  : Marks the tax lines as delete.          |
 * ===========================================================================*/

  PROCEDURE Mark_Tax_Lines_Delete
       (x_return_status           OUT NOCOPY VARCHAR2,
        p_transaction_line_rec IN            ZX_API_PUB.TRANSACTION_LINE_REC_TYPE) IS

    l_return_status VARCHAR2(1);
    l_error_buffer  VARCHAR2(100);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Mark_Tax_Lines_Delete.BEGIN',
                     'ZX_TRL_PUB_PKG: Mark_Tax_Lines_Delete (+)');
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    ZX_TRL_MANAGE_TAX_PKG.Mark_Detail_Tax_Lines_Delete
                      (x_return_status        => l_return_status ,
                       p_transaction_line_rec => p_transaction_line_rec);


    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Mark_Tax_Lines_Delete.END',
                     'ZX_TRL_PUB_PKG.Mark_Tax_Lines_Delete (-)'||x_return_status);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Mark_Tax_Lines_Delete',
                       'Return Status = ' || x_return_status);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Mark_Tax_Lines_Delete',
                        l_error_buffer);
      END IF;

  END Mark_Tax_Lines_Delete;

/*============================================================================*
 | PROCEDURE Manage_TaxDistributions: It will create, update, delete tax      |
 |                                    distributions lines and update tax lines|
 |                                    and summary tax lines in the            |
 |                                    tax repository.                         |
 |============================================================================*/

  PROCEDURE Manage_TaxDistributions
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

    l_return_status  VARCHAR2(1);
    l_error_buffer  VARCHAR2(100);
    l_msg_context_info_rec         ZX_API_PUB.CONTEXT_INFO_REC_TYPE
;


  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxDistributions.BEGIN',
                     'ZX_TRL_PUB_PKG: Manage_TaxDistributions (+)');
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- bug#4893261- populate message structure
    --
    l_msg_context_info_rec.application_id :=
              p_event_class_rec.application_id;
    l_msg_context_info_rec.entity_code :=
              p_event_class_rec.entity_code;
    l_msg_context_info_rec.event_class_code :=
              p_event_class_rec.event_class_code;
    l_msg_context_info_rec.trx_id := NULL;
   --         p_event_class_rec.trx_id;
    l_msg_context_info_rec.trx_line_id := NULL;
    l_msg_context_info_rec.trx_level_type := NULL;
    l_msg_context_info_rec.summary_tax_line_number := NULL;
    l_msg_context_info_rec.tax_line_id := NULL;
    l_msg_context_info_rec.trx_line_dist_id := NULL;


    IF (p_event_class_rec.tax_event_type_code <> 'OVERRIDE_TAX_DISTRIBUTIONS') THEN
    -- bugfix 5551973
    -- this part handles the tax event type of DISTRIBUTE and RE-DISTRIBUTE
    -- If separate logic is required for any other events, it should be handled separetely.

      -- the call to ZX_TRL_MANAGE_TAX_PKG.Delete_dist_Marked_For_Delete is needed
      -- only for re-distribute event. make this call conditional later on
      ZX_TRL_MANAGE_TAX_PKG.Delete_dist_Marked_For_Delete
                          (x_return_status   => l_return_status ,
                           p_event_class_rec => p_event_class_rec);


      IF (l_return_status= FND_API.G_RET_STS_SUCCESS) THEN
        ZX_TRL_MANAGE_TAX_PKG.Create_Tax_Distributions
                            (x_return_status => l_return_status);

      END IF;

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        FND_MESSAGE.SET_NAME('ZX','ZX_TRL_RECORD_ALREADY_EXISTS');
        ZX_API_PUB.add_msg(l_msg_context_info_rec);
      END IF;

      IF (l_return_status= FND_API.G_RET_STS_SUCCESS) THEN
        ZX_TRL_MANAGE_TAX_PKG.Update_Taxline_Rec_Nrec_amt
                            (x_return_status   => l_return_status ,
                             p_event_class_rec => p_event_class_rec);

      END IF;

    ELSIF p_event_class_rec.tax_event_type_code = 'OVERRIDE_TAX_DISTRIBUTIONS' THEN

      -- confirm that  tax_event_type_code = 'OVERRIDE_TAX_DISTRIBUTIONS'
      -- will not be there in the bulk call to determine recovery. Otherwise these API
      -- calls need a change for bulk processing of override deistributions

      ZX_TRL_MANAGE_TAX_PKG.delete_tax_distributions(
                           x_return_status   => l_return_status,
                           p_event_class_rec => p_event_class_rec);

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        ZX_TRL_MANAGE_TAX_PKG.Create_Tax_Distributions
                            (x_return_status => l_return_status);

      END IF;

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        ZX_TRL_MANAGE_TAX_PKG.update_taxline_rec_nrec_amt(
                             x_return_status   => l_return_status,
                             p_event_class_rec => p_event_class_rec);

      END IF;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxDistributions.END',
                     'ZX_TRL_PUB_PKG: Manage_TaxDistributions (-)'||x_return_status);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxDistributions',
                       'Return Status = ' || x_return_status);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Manage_TaxDistributions',
                        l_error_buffer);
      END IF;
  END Manage_TaxDistributions;

/*=====================================================================================*
 | PROCEDURE Freeze_TaxDistributions: This recording service is used to freeze tax     |
 |                                    distributions whenever user freezes transaction  |
 |                                    distribution lines                               |
 |=====================================================================================*/

  PROCEDURE Freeze_TaxDistributions
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec    IN         ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

    l_error_buffer  VARCHAR2(100);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Freeze_TaxDistributions.BEGIN',
                     'ZX_TRL_PUB_PKG: Freeze_TaxDistributions (+)');
    END IF;

    ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag
                      (x_return_status         =>      x_return_status,
                       p_event_class_rec       =>      p_event_class_rec);


    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Freeze_TaxDistributions.END',
                     'ZX_TRL_PUB_PKG: Freeze_TaxDistributions (-)'||x_return_status);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Freeze_TaxDistributions',
                       'Return Status = ' || x_return_status);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Freeze_TaxDistributions',
                        l_error_buffer);
      END IF;
  END Freeze_TaxDistributions;

/*============================================================================*
 | PROCEDURE Update_Taxlines: This recording service is used to update tax    |
 |                            lines (ZX_LINES) with changed status for given  |
 |                            transaction line distributions.                 |
 |============================================================================*/
  PROCEDURE Update_Taxlines
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

    l_error_buffer  VARCHAR2(100);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Update_Taxlines.BEGIN',
                     'ZX_TRL_PUB_PKG: Update_Taxlines (+)');
    END IF;

    ZX_TRL_MANAGE_TAX_PKG.Update_Item_Dist_Changed_Flag
                      (x_return_status   => x_return_status,
                       p_event_class_rec => p_event_class_rec);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Update_Taxlines.END',
                     'ZX_TRL_PUB_PKG: Update_Taxlines (-)'||x_return_status);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Update_Taxlines',
                       'Return Status = ' || x_return_status);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Update_Taxlines',
                        l_error_buffer);
      END IF;
  END Update_Taxlines;

  PROCEDURE Discard_Tax_Only_Lines
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

    l_error_buffer  VARCHAR2(100);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Discard_Tax_Only_Lines.BEGIN',
                     'ZX_TRL_PUB_PKG: Discard_Tax_Only_Lines (+)');
    END IF;

    ZX_TRL_MANAGE_TAX_PKG.Discard_Tax_Only_Lines (x_return_status, p_event_class_rec);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Discard_Tax_Only_Lines.END',
                     'ZX_TRL_PUB_PKG: Discard_Tax_Only_Lines (-)'||x_return_status);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Discard_Tax_Only_Lines',
                       'Return Status = ' || x_return_status);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Discard_Tax_Only_Lines',
                        l_error_buffer);
      END IF;

  END Discard_Tax_Only_Lines;

  PROCEDURE Update_GL_Date
       (p_gl_date       IN            DATE,
        x_return_status    OUT NOCOPY VARCHAR2) IS

    l_error_buffer  VARCHAR2(100);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Update_GL_Date.BEGIN',
                     'ZX_TRL_PUB_PKG: Update_GL_Date (+)');
    END IF;

    ZX_TRL_MANAGE_TAX_PKG.Update_GL_Date (p_gl_date, x_return_status);


    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Update_GL_Date.END',
                     'ZX_TRL_PUB_PKG: Update_GL_Date (-)'||x_return_status);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Update_GL_Date',
                       'Return Status = ' || x_return_status);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Update_GL_Date',
                        l_error_buffer);
      END IF;

  END Update_GL_Date;

  PROCEDURE Update_Exchange_Rate
       (p_event_class_rec         IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
        x_return_status              OUT NOCOPY VARCHAR2) IS

    l_error_buffer  VARCHAR2(100);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Update_Exchange_Rate.BEGIN',
                     'ZX_TRL_PUB_PKG: Update_Exchange_Rate (+)');
    END IF;

    ZX_TRL_MANAGE_TAX_PKG.Update_Exchange_Rate (p_event_class_rec,
                                                  x_return_status);


    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_PUB_PKG.Update_Exchange_Rate.END',
                     'ZX_TRL_PUB_PKG: Update_Exchange_Rate (-)'||x_return_status);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Update_Exchange_Rate',
                       'Return Status = ' || x_return_status);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.Update_Exchange_Rate',
                        l_error_buffer);
      END IF;

  END Update_Exchange_Rate;

------------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  delete_tax_lines_and_dists
--
--  DESCRIPTION
--  Delete all the detail tax lines and distributions of the passed-in
--  transaction line from zx_lines and zx_rec_nrec_dist.
------------------------------------------------------------------------------

PROCEDURE delete_tax_lines_and_dists
(
    p_application_id       IN           NUMBER,
    p_entity_code          IN           VARCHAR2,
    p_event_class_code     IN           VARCHAR2,
    p_trx_id               IN           NUMBER,
    p_trx_line_id          IN           NUMBER,
    p_trx_level_type       IN           VARCHAR2,
    x_return_status        OUT NOCOPY   VARCHAR2
) IS

 CURSOR c_get_summary_flags IS
   SELECT summarization_flag,
          retain_summ_tax_line_id_flag
     FROM zx_evnt_cls_mappings
    WHERE event_class_code = p_event_class_code
      AND application_id   = p_application_id
      AND entity_code      = p_entity_code;

 l_summarization_flag            VARCHAR2(1);
 l_retain_summ_tax_line_id_flag  VARCHAR2(1);

 l_error_buffer VARCHAR2(100);

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.delete_tax_lines_and_dists.BEGIN',
                   'ZX_TRL_PUB_PKG: delete_tax_lines_and_dists (+)');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- delete the distributions
  DELETE FROM zx_rec_nrec_dist
        WHERE application_id     = p_application_id
          AND entity_code        = p_entity_code
          AND event_class_code   = p_event_class_code
          AND trx_id             = p_trx_id
          AND trx_line_id        = p_trx_line_id
          AND trx_level_type     = p_trx_level_type;

  OPEN c_get_summary_flags;
  FETCH c_get_summary_flags into l_summarization_flag, l_retain_summ_tax_line_id_flag;
  CLOSE c_get_summary_flags;

  -- delete the tax detail lines
  DELETE FROM zx_lines
        WHERE application_id     = p_application_id
          AND entity_code        = p_entity_code
          AND event_class_code   = p_event_class_code
          AND trx_id             = p_trx_id
          AND trx_line_id        = p_trx_line_id
          AND trx_level_type     = p_trx_level_type;

  IF l_summarization_flag = 'Y' THEN

    -- for current phase, just delete all the summary tax lines
    -- for this transaction and recreate

    -- delete the summary tax lines for the transaction
    DELETE FROM zx_lines_summary
      WHERE application_id     = p_application_id
        AND entity_code        = p_entity_code
        AND event_class_code   = p_event_class_code
        AND trx_id             = p_trx_id;

    ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_del_evnt(
      p_application_id    => p_application_id,
      p_entity_code       => p_entity_code,
      p_event_class_code  => p_event_class_code,
      p_trx_id            => p_trx_id,
      p_trx_line_id       => p_trx_line_id,
      p_trx_level_type    => p_trx_level_type,
      p_retain_summ_tax_line_id_flag
                          => l_retain_summ_tax_line_id_flag,
      x_return_status     => x_return_status
    );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TRL_PUB_PKG.delete_tax_lines_and_dists',
               'MRC Lines: Incorrect return_status after calling ' ||
               'ZX_TRL_MANAGE_TAX_PKG.create_summary_from_zx_liness()');
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TRL_PUB_PKG.delete_tax_lines_and_dists',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TRL_PUB_PKG.delete_tax_lines_and_dists.END',
               'ZX_TRL_PUB_PKG.delete_tax_lines_and_dists(-)');
      END IF;
      RETURN;
    END IF;

  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.delete_tax_lines_and_dists.END',
                   'ZX_TRL_PUB_PKG: delete_tax_lines_and_dists (-)'||x_return_status);
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.delete_tax_lines_and_dists',
                       'Return Status = ' || x_return_status);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.delete_tax_lines_and_dists',
                        l_error_buffer);
      END IF;

END delete_tax_lines_and_dists;

------------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  delete_tax_dists
--
--  DESCRIPTION
--  Delete all the detail tax distributions of the passed-in transaction
--  line from zx_rec_nrec_dist.
------------------------------------------------------------------------------

PROCEDURE delete_tax_dists
(
    p_application_id       IN           NUMBER,
    p_entity_code          IN           VARCHAR2,
    p_event_class_code     IN           VARCHAR2,
    p_trx_id               IN           NUMBER,
    p_trx_line_id          IN           NUMBER,
    p_trx_level_type       IN           VARCHAR2,
    x_return_status        OUT NOCOPY   VARCHAR2
) IS

 l_error_buffer VARCHAR2(100);

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.delete_tax_dists.BEGIN',
                   'ZX_TRL_PUB_PKG: delete_tax_dists (+)');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM zx_rec_nrec_dist
        WHERE application_id     = p_application_id
          AND entity_code        = p_entity_code
          AND event_class_code   = p_event_class_code
          AND trx_id             = p_trx_id
          AND trx_line_id        = p_trx_line_id
          AND trx_level_type     = p_trx_level_type;

  IF SQL%ROWCOUNT > 0 THEN
    UPDATE zx_lines
       SET process_for_recovery_flag   = 'Y',  -- DECODE(L.Reporting_Only_Flag, 'N', 'Y', 'N')
           rec_tax_amt                 = NULL,
           rec_tax_amt_tax_curr        = NULL,
           rec_tax_amt_funcl_curr      = NULL,
           nrec_tax_amt                = NULL,
           nrec_tax_amt_tax_curr       = NULL,
           nrec_tax_amt_funcl_curr     = NULL
     WHERE application_id     = p_application_id
       AND entity_code        = p_entity_code
       AND event_class_code   = p_event_class_code
       AND trx_id             = p_trx_id
       AND trx_line_id        = p_trx_line_id
       AND trx_level_type     = p_trx_level_type;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRL_PUB_PKG.delete_tax_dists.END',
                   'ZX_TRL_PUB_PKG: delete_tax_dists (-)'||x_return_status);
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.delete_tax_dists',
                       'Return Status = ' || x_return_status);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_PUB_PKG.delete_tax_dists',
                        l_error_buffer);
      END IF;

END delete_tax_dists;

--   Package constructor
--
-------------------------------------------------------------------------------

END ZX_TRL_PUB_PKG;

/
