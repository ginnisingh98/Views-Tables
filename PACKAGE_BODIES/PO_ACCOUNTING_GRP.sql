--------------------------------------------------------
--  DDL for Package Body PO_ACCOUNTING_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ACCOUNTING_GRP" AS
/* $Header: POXGACTB.pls 120.3 2005/10/11 11:20:14 vinokris noship $*/

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_pkg_name      CONSTANT VARCHAR2(30) := 'PO_ACCOUNTING_GRP';
g_module_prefix CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';

-------------------------------------------------------------------------------
--Start of Comments
--Name: build_offset_account
--Function:
--  Given the base account and the overlay account, this API builds a
--  new offset account by overlaying them in the appropriate way determined
--  by the Purchasing option "Automatic Offset Method":
--
--  - Balancing: Most of the segments are copied from the base account, except
--      for the balancing segment, which is copied from the overlay account.
--  - Account: Most of the segments are copied from the overlay account, except
--      for the account segment, which is copied from the base account.
--  - None: In this case, the offset account is the same as the base account,
--      so the API will just return the base account. (Note: It will not
--      validate the base account.)
--Parameters:
--IN:
--p_api_version
--  API version number expected by the caller.
--p_init_msg_list
--  If FND_API.G_TRUE, the API will initialize the standard API message list.
--p_base_ccid
--  base account on which the overlaying will be done; ex. receiving inspection
--  account.
--p_overlay_ccid
--  overlay account, whose segments will be used to overlay onto the base
--  account; ex. charge account from the PO distribution.
--p_accounting_date
--  date used by Flexbuilder to validate/generate the account ccid.
--p_org_id
--  operating unit for retrieving the set of books and Automatic Offset Method.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if the API successfully built the offset account.
--  FND_API.G_RET_STS_ERROR if the offset account could not be built, for
--    example if the base account, overlay account, or offset account fails
--    Flexbuilder validation. The error message will be returned on the
--    standard API message list.
--  FND_API.G_RET_STS_UNEXP_ERROR if an unexpected error occurred.
--x_result_ccid
--  the resulting offset account, if x_return_status=FND_API.G_RET_STS_SUCCESS.
--Notes:
--  This procedure is adapted from AP_ACCOUNTING_MAIN_PKG.build_offset_account.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE build_offset_account (
  p_api_version     IN NUMBER,
  p_init_msg_list   IN VARCHAR2,
  x_return_status   OUT NOCOPY VARCHAR2,
  p_base_ccid       IN NUMBER,
  p_overlay_ccid    IN NUMBER,
  p_accounting_date IN DATE,
  p_org_id          IN NUMBER,
  x_result_ccid     OUT NOCOPY NUMBER
) IS
  l_api_version CONSTANT NUMBER := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'BUILD_OFFSET_ACCOUNT';

  l_auto_offset_method    PO_SYSTEM_PARAMETERS.auto_offset_method%TYPE;
  l_coa_id                GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;
  l_qualifier_segment_num NUMBER;
  l_base_segments         FND_FLEX_EXT.SEGMENTARRAY;
  l_overlay_segments      FND_FLEX_EXT.SEGMENTARRAY;
  l_result_segments       FND_FLEX_EXT.SEGMENTARRAY;
  l_num_of_segments       NUMBER;
  l_result                BOOLEAN;
BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name,
                    'Entering ' || l_api_name
                    || '; p_base_ccid: ' || p_base_ccid
                    || ' p_overlay_ccid: ' || p_overlay_ccid
                    || ' p_accounting_date: ' || p_accounting_date );
    END IF;
  END IF;

  -- Standard API initialization:
  IF NOT FND_API.compatible_api_call ( l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- SQL What: Retrieve the Automatic Offset Method and chart of accounts
  --           for the given operating unit.
  -- SQL Why:  Need these parameters to generate the offset account.
  SELECT PSP.auto_offset_method,
         SOB.chart_of_accounts_id
  INTO l_auto_offset_method,
       l_coa_id
  FROM po_system_parameters_all PSP,
       financials_system_params_all FSP,
       gl_sets_of_books SOB
  WHERE NVL(PSP.org_id,-99) = NVL(p_org_id,-99)
  AND   NVL(FSP.org_id,-99) = NVL(p_org_id,-99)
  AND   FSP.set_of_books_id = SOB.set_of_books_id; -- JOIN

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
      FND_LOG.string( FND_LOG.LEVEL_EVENT, g_module_prefix || l_api_name,
                    'Automatic offset method: ' || l_auto_offset_method );
    END IF;
  END IF;

  -- For Automatic Offset Method of "None", the offset account is the
  -- same as the base account.
  IF (l_auto_offset_method IS NULL) THEN
    x_result_ccid := p_base_ccid;
    RETURN;
  END IF;

  -- Validate the base account.
  l_result := FND_FLEX_KEYVAL.validate_ccid (
                appl_short_name => 'SQLGL',
                key_flex_code => 'GL#',
                structure_number => l_coa_id,
                combination_id => p_base_ccid );
  IF (NOT l_result) THEN
    -- Add the error to the standard API message list.
    FND_MESSAGE.set_encoded(FND_FLEX_KEYVAL.encoded_error_message);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- validate_ccid retrieved the base account segments into the package
  -- variable segment_value. Copy them into l_base_segments.
  l_num_of_segments := FND_FLEX_KEYVAL.segment_count;
  FOR i in 1..l_num_of_segments LOOP
    l_base_segments(i) := FND_FLEX_KEYVAL.segment_value(i);
  END LOOP;

  -- Validate the overlay account.
  l_result := FND_FLEX_KEYVAL.validate_ccid (
                appl_short_name => 'SQLGL',
                key_flex_code => 'GL#',
                structure_number => l_coa_id,
                combination_id => p_overlay_ccid );
  IF (NOT l_result) THEN
    -- Add the error to the standard API message list.
    FND_MESSAGE.set_encoded(FND_FLEX_KEYVAL.encoded_error_message);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- validate_ccid retrieved the overlay account segments into the package
  -- variable segment_value. Copy them into l_overlay_segments.
  l_num_of_segments := FND_FLEX_KEYVAL.segment_count;
  FOR i in 1..l_num_of_segments  LOOP
    l_overlay_segments(i) := FND_FLEX_KEYVAL.segment_value(i);
  END LOOP;

  -- Get the qualifier segment number for the Automatic Offset Method.
  l_result := FND_FLEX_APIS.get_qualifier_segnum (
                appl_id => 101,
                key_flex_code => 'GL#',
                structure_number => l_coa_id,
                flex_qual_name => l_auto_offset_method,
                segment_number => l_qualifier_segment_num );
  IF (NOT l_result) THEN
    FND_MESSAGE.set_name('PO', 'PO_GENERIC_ERROR');
    FND_MESSAGE.set_token('ERROR_TEXT',
      'Could not retrieve the qualifier segment; automatic offset method: '
      || l_auto_offset_method);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
      FND_LOG.string( FND_LOG.LEVEL_EVENT, g_module_prefix || l_api_name,
                    'Qualifier segment number: ' || l_qualifier_segment_num );
    END IF;
  END IF;

  -- Overlay the account segments according to the Automatic Offset Method:
  -- Note: [] indicates the qualifier segment.
  --
  -- Case 1: Account Segment Overlay (GL_ACCOUNT)
  --  Base      A    A    [A]  A
  --  Overlay   B    B    [B]  B
  --  Result    B    B    [A]  B
  --
  -- Case 2: Balancing Segment Overlay (GL_BALANCING)
  --  Base      [A]  A    A    A
  --  Overlay   [B]  B    B    B
  --  Result    [B]  A    A    A

  -- Construct the segments of the new offset account.
  FOR i IN 1..l_num_of_segments LOOP

    IF (l_auto_offset_method = 'GL_ACCOUNT') THEN
      -- Case 1: Account Segment Overlay
      IF (i = l_qualifier_segment_num) THEN
        l_result_segments(i) := l_base_segments(i);
      ELSE
        l_result_segments(i) := l_overlay_segments(i);
      END IF;

    ELSIF (l_auto_offset_method = 'GL_BALANCING') THEN
      -- Case 2: Balancing Segment Overlay
      IF (i = l_qualifier_segment_num) THEN
        l_result_segments(i) := l_overlay_segments(i);
      ELSE
        l_result_segments(i) := l_base_segments(i);
      END IF;

    ELSE -- Invalid automatic offset method
      FND_MESSAGE.set_name('PO', 'PO_GENERIC_ERROR');
      FND_MESSAGE.set_token('ERROR_TEXT',
        'Invalid automatic offset method: ' || l_auto_offset_method);
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF; -- l_auto_offset_method

  END LOOP;

  -- (For debugging purposes) Write the offset account segments to the log,
  -- if logging is enabled at the statement level.
  -- Bug 4618614: Workaround GSCC error for checking logging statement.
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string ( FND_LOG.LEVEL_STATEMENT, g_module_prefix || l_api_name,
                       'Offset account segments:' );

    END IF;
    FOR i IN 1..l_num_of_segments LOOP

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string ( FND_LOG.LEVEL_STATEMENT,
                         g_module_prefix || l_api_name, l_result_segments(i) );
      END IF;
    END LOOP;

  END IF;

  -- Retrieve the ccid of the new offset account.
  l_result := FND_FLEX_EXT.get_combination_id (
                application_short_name => 'SQLGL',
                key_flex_code => 'GL#',
                structure_number => l_coa_id,
                validation_date => p_accounting_date,
                n_segments => l_num_of_segments,
                segments => l_result_segments,
                combination_id => x_result_ccid );
  IF (NOT l_result) THEN
    -- get_combination_id returned the error message on the stack.
    -- Add it to the standard API message list.
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name,
                    'Exiting ' || l_api_name
                    || '; x_result_ccid: ' || x_result_ccid );
    END IF;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
        FND_LOG.string ( FND_LOG.LEVEL_ERROR,
                       g_module_prefix || l_api_name,
                       FND_MSG_PUB.get ( p_msg_index => FND_MSG_PUB.G_LAST,
                                         p_encoded => FND_API.G_FALSE ));
      END IF;
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string ( FND_LOG.LEVEL_UNEXPECTED,
                       g_module_prefix || l_api_name,
                       FND_MSG_PUB.get ( p_msg_index => FND_MSG_PUB.G_LAST,
                                         p_encoded => FND_API.G_FALSE ));
      END IF;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg ( G_PKG_NAME, l_api_name );
    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string ( FND_LOG.LEVEL_UNEXPECTED,
                       g_module_prefix || l_api_name,
                       FND_MSG_PUB.get ( p_msg_index => FND_MSG_PUB.G_LAST,
                                         p_encoded => FND_API.G_FALSE ));
      END IF;
    END IF;
END build_offset_account;

END PO_ACCOUNTING_GRP;

/
