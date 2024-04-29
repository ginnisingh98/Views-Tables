--------------------------------------------------------
--  DDL for Package Body FUN_BAL_UTILS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_BAL_UTILS_GRP" AS
/* $Header: fungbalutilb.pls 120.7.12010000.12 2010/02/05 06:05:03 srampure ship $ */
g_debug_level       NUMBER;
g_package_name      VARCHAR2(30) := 'FUN_BAL_UTILS_GRP';

CURSOR c_get_le_id (p_ledger_id     NUMBER,
                    p_bsv           VARCHAR2,
                    p_gl_date       DATE)
IS
   SELECT  vals.legal_entity_id
   FROM    gl_ledger_le_bsv_specific_v vals
   WHERE   vals.segment_value     = p_bsv
   AND     vals.ledger_id         = p_ledger_id
   AND    (TRUNC(p_gl_date) BETWEEN TRUNC(NVL(vals.start_date, p_gl_date)) AND
                                 TRUNC(NVL(vals.end_date, p_gl_date)));

CURSOR c_get_seg_num(p_ledger_id     NUMBER,
                     p_segment_type   VARCHAR2)
IS
  SELECT fun_bal_pkg.get_segment_index(ledgers.chart_of_accounts_id,
                                       p_segment_type),
         ledgers.chart_of_accounts_id
  FROM gl_ledgers ledgers
  WHERE ledgers.ledger_id = p_ledger_id;

/* ----------------------------------------------------------------------------
--	API name 	: FUN_BAL_UTILS_GRP.get_inter_intra_account
--	Type		: Group
--	Pre-reqs	: None.
--	Function	: Given a transacting and trading Balancing segment value, the
--                        the procedure determines what type of account is required
--                        ie inter or intra company accounts and returns the same
--	Parameters	:
--	IN		:
--              p_api_version               IN NUMBER   Required
--              p_init_msg_list	            IN VARCHAR2 Optional
--              p_ledger_id                 IN NUMBER   Required
--              p_from_bsv                  IN VARCHAR2 Required
--              p_to_bsv                    IN VARCHAR2 Required
--              p_source                    IN VARCHAR2 Optional
--              p_category                  IN VARCHAR2 Optional
--              p_gl_date                   IN DATE     Required
--              p_acct_type                 IN VARCHAR2 Required
--                   Account type would be 'D'ebit(Receivables)
--                   Or                    'C'redit' (Payables)
--
--	OUT		:
--              x_status                    VARCHAR2
--              x_msg_count                 NUMBER
--              x_msg_data                  VARCHAR2
--              x_ccid                      VARCHAR2   CCID requested
--              x_reciprocal_ccid           VARCHAR2   Reciprocal CCID
--                   Eg. If receivable account ccid is requested for BSV1 => BSV2
--                   x_reciprocal_ccid will contain the payable account for
--                   BSV2 => BSV1
--
--	Version	: Current version	1.0
--		  Previous version 	1.0
--		  Initial version 	1.0
------------------------------------------------------------------------------*/
PROCEDURE get_inter_intra_account (p_api_version       IN     NUMBER,
                                    p_init_msg_list     IN     VARCHAR2 default FND_API.G_FALSE,
                                    p_ledger_id         IN     NUMBER,
                                    p_to_ledger_id         IN     NUMBER,
                                    p_from_bsv          IN     VARCHAR2,
                                    p_to_bsv            IN     VARCHAR2,
                                    p_source            IN     VARCHAR2,
                                    p_category          IN     VARCHAR2,
                                    p_gl_date           IN     DATE,
                                    p_acct_type         IN     VARCHAR2,
                                    x_status            IN OUT NOCOPY VARCHAR2,
                                    x_msg_count         IN OUT NOCOPY NUMBER,
                                    x_msg_data          IN OUT NOCOPY VARCHAR2,
                                    x_ccid              IN OUT NOCOPY NUMBER ,
                                    x_reciprocal_ccid   IN OUT NOCOPY NUMBER)
IS


  l_api_name         CONSTANT VARCHAR2(30)   := 'Get_Inter_Intra_Account';
  l_api_version      CONSTANT NUMBER         := 1.0;
  l_return_status    VARCHAR2(1);
  l_from_le_id       NUMBER ;
  l_to_le_id         NUMBER;
  l_intra_txn        BOOLEAN := FALSE;
  l_inter_txn        BOOLEAN := FALSE;
  l_acct_type        VARCHAR2(1);

BEGIN

  -- variable p_validation_level is not used .
  g_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
  THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'fun.plsql.fun_bal_utils_grp.get_inter_intra_account.begin',
                     'begin');
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_package_name )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
      FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_get_le_id (p_ledger_id     => p_ledger_id,
                    p_bsv           => p_from_bsv,
                    p_gl_date       => p_gl_date);
  FETCH c_get_le_id INTO l_from_le_id;
  CLOSE c_get_le_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
  THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'fun.plsql.fun_bal_utils_grp.get_inter_intra_account.frm_le',
                     'Fetched From LE Id : ' || l_from_le_id);
  END IF;


  OPEN c_get_le_id (p_ledger_id     => p_to_ledger_id,
                    p_bsv           => p_to_bsv,
                    p_gl_date       => p_gl_date);
  FETCH c_get_le_id INTO l_to_le_id;
  CLOSE c_get_le_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
  THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'fun.plsql.fun_bal_utils_grp.get_inter_intra_account.to_le',
                     'Fetching To LE Id : ' ||l_to_le_id);
  END IF;

  IF Nvl(l_from_le_id,-99) =  Nvl(l_to_le_id, -99)
  THEN
      -- This is an intracompany transaction
      l_intra_txn := TRUE;
  END IF;

  IF l_from_le_id <>  l_to_le_id
  THEN
      -- This is an intercompany transaction
      l_inter_txn := TRUE;
  END IF;

  IF NOT(l_inter_txn)  AND NOT(l_intra_txn)
  THEN
      -- This is an error situation
      FND_MESSAGE.SET_NAME('FUN', 'FUN_INTER_BSV_NOT_ASSIGNED');
      FND_MSG_PUB.Add;
      x_status :=  FND_API.G_RET_STS_ERROR;
  END IF;

  IF l_inter_txn
  THEN
      IF p_acct_type  = 'D'
      THEN
          l_acct_type := 'R';
      ELSE
          l_acct_type := 'P';
      END IF;

      IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'fun.plsql.fun_bal_utils_grp.get_inter_intra_account.get',
                         'Fetching intercompany account ');
      END IF;
 --ER: 8588074.
      get_intercompany_account (p_api_version       => p_api_version,
                                p_init_msg_list     => p_init_msg_list,
                                p_ledger_id         => p_ledger_id,
                                p_from_le           => l_from_le_id,
				p_source            => p_source,
                                p_category          => p_category,
                                p_from_bsv          => p_from_bsv,
                                p_to_ledger_id      => p_to_ledger_id,
                                p_to_le             => l_to_le_id,
                                p_to_bsv            => p_to_bsv,
                                p_gl_date           => p_gl_date,
                                p_acct_type         => l_acct_type,
                                x_status            => x_status,
                                x_msg_count         => x_msg_count,
                                x_msg_data          => x_msg_data,
                                x_ccid              => x_ccid,
                                x_reciprocal_ccid   => x_reciprocal_ccid);

  END IF;

  IF l_intra_txn
  THEN

      IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'fun.plsql.fun_bal_utils_grp.get_inter_intra_account.get',
                         'Fetching the intracompany ccid');
      END IF;

      get_intracompany_account (p_api_version       => p_api_version,
                                p_init_msg_list     => p_init_msg_list,
                                p_ledger_id         => p_ledger_id,
                                p_from_le           => l_from_le_id,
                                p_source            => p_source,
                                p_category          => p_category,
                                p_dr_bsv            => p_from_bsv,
                                p_cr_bsv            => p_to_bsv,
                                p_gl_date           => p_gl_date,
                                p_acct_type         => p_acct_type,
                                x_status            => x_status,
                                x_msg_count         => x_msg_count,
                                x_msg_data          => x_msg_data,
                                x_ccid              => x_ccid,
                                x_reciprocal_ccid   => x_reciprocal_ccid);

  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_utils_grp.get_inter_intra_account.end', 'end');
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR
    THEN
       IF (FND_LOG.LEVEL_ERROR>= g_debug_level)
       THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
	                 'fun.plsql.fun_bal_pkg.get_inter_intra_account.error',
			 SUBSTR(SQLERRM,1, 4000));
       END IF;

       x_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
       IF (FND_LOG.LEVEL_ERROR>= g_debug_level)
       THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
	                'fun.plsql.fun_bal_utils_grp.get_inter_intra_account.unexpected_error_norm',
			SUBSTR(SQLCODE ||' : ' || SQLERRM,1, 4000));
       END IF;

       x_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS
    THEN
       IF (FND_LOG.LEVEL_ERROR>= g_debug_level)
       THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
	                 'fun.plsql.fun_bal_utils_grp.get_inter_intra_account.unexpected_error_others',
 		          SUBSTR(SQLCODE ||' : ' || SQLERRM,1, 4000));
       END IF;

       IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
          FND_MSG_PUB.Add_Exc_Msg(g_package_name, l_api_name);
       END IF;

       x_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data  => x_msg_data);

END get_inter_intra_account;

/* ----------------------------------------------------------------------------
--	API name 	: FUN_BAL_UTILS_GRP.get_intercompany_account
--	Type		: Group
--	Pre-reqs	: None.
--	Function	: Given a transacting and trading Balancing segment value,
--                        the procedure returns the intercompany receivables and
--                        payables account
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--              p_init_msg_list	            IN VARCHAR2 Optional
--              p_ledger_id                 IN NUMBER   Required
--              p_from_le                   IN NUMBER   Required
--              ER: 8588074
--              p_source                    IN VARCHAR2 Required
--              p_category                  IN VARCHAR2 Required
--              p_from_bsv                  IN VARCHAR2 Required
--              p_to_le                     IN NUMBER   Required
--              p_to_bsv                    IN VARCHAR2 Required
--              p_gl_date                   IN DATE     Required
--              p_acct_type                 IN VARCHAR2 Required
--                   Account type would be 'R'eceivables or 'P'ayables
--
--	OUT		:	x_status                    VARCHAR2
--              x_msg_count                 NUMBER
--              x_msg_data                  VARCHAR2
--              x_ccid                      VARCHAR2   CCID requested
--              x_reciprocal_ccid           VARCHAR2   Reciprocal CCID
--                   Eg. If receivable account ccid is requested for BSV1 => BSV2
--                   x_reciprocal_ccid will contain the payable account for
--                   BSV2 => BSV1
--
--	Version	: Current version	1.0
--		  Previous version 	1.0
--		  Initial version 	1.0
------------------------------------------------------------------------------*/


PROCEDURE get_intercompany_account (p_api_version       IN     NUMBER,
                                    p_init_msg_list     IN     VARCHAR2,
                                    p_ledger_id         IN     NUMBER,
                                    p_from_le           IN     NUMBER,
                                    p_source            IN     VARCHAR2,
                                    p_category          IN     VARCHAR2,
                                    p_from_bsv          IN     VARCHAR2,
                                    p_to_ledger_id      IN     NUMBER,
                                    p_to_le             IN     NUMBER,
                                    p_to_bsv            IN     VARCHAR2,
                                    p_gl_date           IN     DATE,
                                    p_acct_type         IN     VARCHAR2,
                                    x_status            IN OUT NOCOPY VARCHAR2,
                                    x_msg_count         IN OUT NOCOPY NUMBER,
                                    x_msg_data          IN OUT NOCOPY VARCHAR2,
                                    x_ccid              IN OUT NOCOPY NUMBER ,
                                    x_reciprocal_ccid   IN OUT NOCOPY NUMBER)
IS
--Bug: 9337184
CURSOR c_get_ccid (p_ledger_id         NUMBER,
                   p_from_le_id        NUMBER,
                   p_to_le_id          NUMBER,
                   p_from_bsv          VARCHAR2,
                   p_to_bsv            VARCHAR2,
                   p_acct_type         VARCHAR2,
                   p_gl_date           DATE)
IS
SELECT  NVL( (SELECT ccid
      FROM fun_inter_accounts accts
      WHERE accts.ledger_id   = p_ledger_id
      AND   accts.from_le_id  = p_from_le_id
      AND   accts.to_le_id    = p_to_le_id
      AND   accts.trans_bsv   = p_from_bsv
      AND   accts.tp_bsv      = p_to_bsv
      AND   accts.type        = p_acct_type
      AND   accts.default_flag = 'Y'
      AND   (TRUNC(p_gl_date) BETWEEN TRUNC(NVL(accts.start_date, p_gl_date))
                                    AND TRUNC(NVL(accts.end_date, p_gl_date)))),
      NVL((SELECT ccid
      FROM fun_inter_accounts accts
      WHERE accts.ledger_id   = p_ledger_id
      AND   accts.from_le_id  = p_from_le_id
      AND   accts.to_le_id    = p_to_le_id
      AND   accts.trans_bsv   = p_from_bsv
      AND   accts.tp_bsv      = 'OTHER1234567890123456789012345'
      AND   accts.type        = p_acct_type
      AND   accts.default_flag = 'Y'
      AND   (TRUNC(p_gl_date) BETWEEN TRUNC(NVL(accts.start_date, p_gl_date))
                                    AND TRUNC(NVL(accts.end_date, p_gl_date)))),
      NVL((SELECT ccid
      FROM fun_inter_accounts accts
      WHERE accts.ledger_id   = p_ledger_id
      AND   accts.from_le_id  = p_from_le_id
      AND   accts.to_le_id    = p_to_le_id
      AND   accts.trans_bsv   = 'OTHER1234567890123456789012345'
      AND   accts.tp_bsv      = p_to_bsv
      AND   accts.type        = p_acct_type
      AND   accts.default_flag = 'Y'
      AND   (TRUNC(p_gl_date) BETWEEN TRUNC(NVL(accts.start_date, p_gl_date))
                              AND TRUNC(NVL(accts.end_date, p_gl_date)))),
      NVL((SELECT ccid
      FROM fun_inter_accounts accts
      WHERE accts.ledger_id   = p_ledger_id
      AND   accts.from_le_id  = p_from_le_id
      AND   accts.to_le_id    = p_to_le_id
      AND   accts.trans_bsv   = 'OTHER1234567890123456789012345'
      AND   accts.tp_bsv      = 'OTHER1234567890123456789012345'
      AND   accts.type        = p_acct_type
      AND   accts.default_flag = 'Y'
      AND   (TRUNC(p_gl_date) BETWEEN TRUNC(NVL(accts.start_date, p_gl_date))
                              AND TRUNC(NVL(accts.end_date, p_gl_date)))),
     NVL((SELECT ccid
      FROM fun_inter_accounts accts
      WHERE accts.ledger_id   = p_ledger_id
      AND   accts.from_le_id  = p_from_le_id
      AND   accts.to_le_id    = -99
      AND   accts.trans_bsv   = p_from_bsv
      AND   accts.tp_bsv      = 'OTHER1234567890123456789012345'
      AND   accts.type        = p_acct_type
      AND   accts.default_flag = 'Y'
      AND   (TRUNC(p_gl_date) BETWEEN TRUNC(NVL(accts.start_date, p_gl_date))
                              AND TRUNC(NVL(accts.end_date, p_gl_date)))),
      (SELECT ccid
      FROM fun_inter_accounts accts
      WHERE accts.ledger_id   = p_ledger_id
      AND   accts.from_le_id  = p_from_le_id
      AND   accts.to_le_id    = -99
      AND   accts.trans_bsv   = 'OTHER1234567890123456789012345'
      AND   accts.tp_bsv      = 'OTHER1234567890123456789012345'
      AND   accts.type        = p_acct_type
      AND   accts.default_flag = 'Y'
      AND   (TRUNC(p_gl_date) BETWEEN TRUNC(NVL(accts.start_date, p_gl_date))
                              AND TRUNC(NVL(accts.end_date, p_gl_date))))))))) ccid
   From Dual;

 -- ER: 8588074
CURSOR c_get_template (p_ledger_id     NUMBER,
                       p_le_id         NUMBER,
                       p_source_name   VARCHAR2,
                       p_category_name VARCHAR2)
IS
SELECT  NVL((SELECT opts.template_id
             FROM  fun_balance_options opts
             WHERE opts.ledger_id        = p_ledger_id
             AND   Nvl(opts.le_id,-99)   = Nvl(p_le_id,-99)
             AND   opts.je_source_name   = p_source_name
             AND   opts.je_category_name = p_category_name
             AND   opts.status_flag      = 'Y'),
      NVL((SELECT opts.template_id
             FROM  fun_balance_options opts
             WHERE opts.ledger_id        = p_ledger_id
             AND   Nvl(opts.le_id,-99)   = Nvl(p_le_id,-99)
             AND   opts.je_source_name   = p_source_name
             AND   opts.je_category_name = 'Other'
             AND   opts.status_flag      = 'Y'),
      NVL((SELECT opts.template_id
             FROM  fun_balance_options opts
             WHERE opts.ledger_id        = p_ledger_id
             AND   Nvl(opts.le_id,-99)   = Nvl(p_le_id,-99)
             AND   opts.je_source_name   = 'Other'
             AND   opts.je_category_name = p_category_name
             AND   opts.status_flag      = 'Y'),
      (SELECT opts.template_id
             FROM  fun_balance_options opts
             WHERE opts.ledger_id        = p_ledger_id
             AND   Nvl(opts.le_id,-99)   = Nvl(p_le_id,-99)
             AND   opts.je_source_name   = 'Other'
             AND   opts.je_category_name = 'Other'
             AND   opts.status_flag      = 'Y')))) template_id
  From Dual;

CURSOR c_get_intra_ccid (p_template_id     NUMBER,
                   p_acct_type       VARCHAR2)
IS
SELECT DECODE (p_acct_type, 'D', accts.dr_ccid, 'C', cr_ccid) ccid
             FROM  fun_balance_accounts accts
             WHERE accts.template_id     = p_template_id
             AND   accts.dr_bsv          = 'OTHER1234567890123456789012345'
             AND   accts.cr_bsv          = 'OTHER1234567890123456789012345' ;


  l_api_name         CONSTANT VARCHAR2(30)   := 'Get_Intercompany_Account';
  l_api_version      CONSTANT NUMBER         := 1.0;
  l_return_status    VARCHAR2(1);
  l_from_le_id       NUMBER ;
  l_to_le_id         NUMBER;
  l_recip_acct_type  VARCHAR2(1);

  l_setup_ccid       NUMBER;
  l_setup_recp_ccid  NUMBER;
  l_coa              NUMBER;
  l_dummy            NUMBER;
  l_ic_seg_num       NUMBER;
  l_bal_seg_num      NUMBER;
  l_recp_coa         NUMBER;
  l_recp_ic_seg_num  NUMBER;
  l_recp_bal_seg_num NUMBER;
  l_insert_flag      VARCHAR2(1)               := 'N';  --8200511
  l_check_ccid 		NUMBER;
  l_template_id      NUMBER;
  l_source           gl_je_sources.je_source_name%TYPE;
  l_category         gl_je_categories.je_category_name%TYPE;
  l_acct_type        VARCHAR2(1);


BEGIN

	l_check_ccid := 0;
  -- variable p_validation_level is not used .
  g_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_utils_grp.get_intercompany_account.begin', 'begin');
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_package_name )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
      FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_status := FND_API.G_RET_STS_SUCCESS;

  IF p_from_le IS NULL OR p_to_le IS NULL
  THEN
      FND_MESSAGE.SET_NAME('FUN', 'FUN_INTER_BSV_NOT_ASSIGNED');
      FND_MSG_PUB.Add;
      x_status :=  FND_API.G_RET_STS_ERROR;
  END IF;

  IF x_status = FND_API.G_RET_STS_SUCCESS
  THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'fun.plsql.fun_bal_utils_grp.get_intercompany_account.get_ccid',
			'Fetching the ccid');
      END IF;

      -- Rules of precedence is to find matching records for the IC Accts using
      -- 1)  From LE, From BSV => To LE, To BSV
      -- 2)  From LE, From BSV => To LE
      -- 3)  From LE           => To LE, To BSV
      -- 4)  From LE           => To LE
      -- 5)  From LE           => To All Others

      OPEN c_get_ccid (p_ledger_id         => p_ledger_id,
                       p_from_le_id        => p_from_le,
                       p_to_le_id          => p_to_le,
                       p_from_bsv          => p_from_bsv,
                       p_to_bsv            => p_to_bsv,
                       p_acct_type         => p_acct_type,
		       p_gl_date           => p_gl_date);
      FETCH c_get_ccid INTO l_setup_ccid;
      CLOSE c_get_ccid;

      --ER: 8588074
      IF l_setup_ccid is NULL THEN

	      IF p_acct_type = 'R'
	      THEN
		  l_acct_type := 'D';
	      ELSE
		  l_acct_type :='C';
	      END IF;
	  l_source   := Nvl(p_source, 'Other');
	  l_category := Nvl(p_category, 'Other');

	  -- Rules of precedence to find template id. Look for  ..
	  -- 1)  Source , Category
	  -- 2)  Source , 'Other'
	  -- 3)  'Other', Category
	  -- 4)  'Other', 'Other'

	  OPEN c_get_template (p_ledger_id     => p_ledger_id,
			       p_le_id         => p_from_le,
			       p_source_name   => l_source,
			       p_category_name => l_category);
	  FETCH c_get_template  INTO l_template_id;
	  CLOSE c_get_template;

	  IF l_template_id IS NOT NULL
	  THEN
	      -- Now get the debit or credit account.
	      -- Rules of precedence to find ccid. Look for  ..
	      -- 1) 'Other', 'Other'
	      OPEN c_get_intra_ccid (p_template_id     => l_template_id,
				       p_acct_type       => l_acct_type);
	      FETCH  c_get_intra_ccid INTO l_setup_ccid;
	      CLOSE  c_get_intra_ccid ;
	  END IF;

  END IF;


      IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'fun.plsql.fun_bal_utils_grp.get_intercompany_account.got_ccid',
			'Fetched the ccid : ' || l_setup_ccid);
      END IF;

      -- Now get the reciprocal account

      IF p_acct_type = 'R'
      THEN
          l_recip_acct_type := 'P';
	  l_acct_type := 'C';
      ELSE
          l_recip_acct_type := 'R';
	  l_acct_type :='D';
      END IF;

      IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
	                'fun.plsql.fun_bal_utils_grp.get_intercompany_account.get_recip_ccid',
			'Fetching the reciprocal ccid');
      END IF;

      OPEN c_get_ccid (p_ledger_id         => p_to_ledger_id,
                       p_from_le_id        => p_to_le,
                       p_to_le_id          => p_from_le,
                       p_from_bsv          => p_to_bsv,
                       p_to_bsv            => p_from_bsv,
                       p_acct_type         => l_recip_acct_type,
		       p_gl_date           => p_gl_date);
      FETCH c_get_ccid INTO l_setup_recp_ccid ;
      CLOSE c_get_ccid;
      IF l_setup_recp_ccid is NULL THEN

      --ER: 8588074
      	  l_source   := Nvl(p_source, 'Other');
	  l_category := Nvl(p_category, 'Other');

	  -- Rules of precedence to find template id. Look for  ..
	  -- 1)  Source , Category
	  -- 2)  Source , 'Other'
	  -- 3)  'Other', Category
	  -- 4)  'Other', 'Other'

	  OPEN c_get_template (p_ledger_id     => p_to_ledger_id,
			       p_le_id         => p_to_le,
			       p_source_name   => l_source,
			       p_category_name => l_category);
	  FETCH c_get_template  INTO l_template_id;
	  CLOSE c_get_template;
  IF l_template_id IS NOT NULL THEN
      -- Now get the debit or credit account.
      -- Rules of precedence to find ccid. Look for  ..
      -- 1)  'Other', 'Other'
      OPEN c_get_intra_ccid (p_template_id     => l_template_id,
                       p_acct_type       => l_acct_type);
      FETCH  c_get_intra_ccid INTO l_setup_recp_ccid;
      CLOSE  c_get_intra_ccid ;


  END IF;
  END IF;

      IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
	                'fun.plsql.fun_bal_utils_grp.get_intercompany_account.got_recip_ccid',
			'Fetched the reciprocal ccid : ' || l_setup_recp_ccid);
      END IF;

	-- Enhancement 7520196 Start
	-- If the Legal entities belong to the same cahrt of accounts, then the intercompany
	-- and balancing segment value of the intercompany accounts are switched with the
	-- participating balancing segment values.

	OPEN c_get_seg_num(p_ledger_id,
					'GL_BALANCING');
	FETCH c_get_seg_num INTO l_bal_seg_num,
                             l_coa;
	CLOSE c_get_seg_num;

	-- Next find out the segment numbers for the Intercompany segment
	OPEN c_get_seg_num(p_ledger_id,
                      'GL_INTERCOMPANY');
    FETCH c_get_seg_num INTO l_ic_seg_num,
                             l_dummy;
    CLOSE c_get_seg_num;

	OPEN c_get_seg_num(p_to_ledger_id,
                      'GL_BALANCING');
    FETCH c_get_seg_num INTO l_recp_bal_seg_num,
                             l_recp_coa;
    CLOSE c_get_seg_num;

    -- Next find out the segment numbers for the Intercompany segment
    OPEN c_get_seg_num(p_to_ledger_id,
                      'GL_INTERCOMPANY');
    FETCH c_get_seg_num INTO l_recp_ic_seg_num,
                             l_dummy;
    CLOSE c_get_seg_num;

    IF l_coa = l_recp_coa
    THEN
	  -- Now we need to generate the new accounts by replacing the intercompany
	  -- segments and the balancing segments
	  -- First find out the segment numbers for the Balancing segment

      IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
	                'fun.plsql.fun_bal_utils_grp.get_intercompany_account.get_new_ccid',
			'Generating new acc using ccid : '||l_setup_ccid ||
                        'Bal BSV :'||p_from_bsv||'IC BSV :' ||p_to_bsv);
      END IF;

      -- Call the procedure to generate the new account
      -- For eg if from the setup table we get back account 99-00-4350-00-99
      -- and if the from bsv is 01 and to bsv is 02, this api should return ccid
      -- for account 01-00-4350-00-02

      x_ccid := fun_bal_pkg.get_ccid (
                             ccid                       => l_setup_ccid,
                             chart_of_accounts_id       => l_coa,
                             bal_seg_val                => p_from_bsv,
                             intercompany_seg_val       => p_to_bsv,
                             bal_seg_column_number      => l_bal_seg_num,
                             intercompany_column_number => l_ic_seg_num,
                             gl_date                    => p_gl_date);

	SELECT count(1)
	INTO l_check_ccid
	FROM   gl_code_combinations cc
	WHERE  x_ccid = cc.code_combination_id
	   AND cc.detail_posting_allowed_flag = 'Y'
	   AND cc.enabled_flag = 'Y'
	   AND cc.summary_flag = 'N'
	   AND Nvl(cc.reference3,'N') = 'N'
	   AND cc.template_id IS NULL
	   AND (Trunc(p_gl_date) BETWEEN
			Trunc(Nvl(cc.start_date_active,p_gl_date)) AND
			Trunc(Nvl(cc.end_date_active,p_gl_date)));

	IF (l_check_ccid = 0)
	THEN
		FND_MESSAGE.SET_NAME('FUN', 'FUN_INTRA_CC_NOT_VALID');
		FND_MSG_PUB.Add;
		x_status :=  FND_API.G_RET_STS_ERROR;

	ELSE
		l_check_ccid := 0;
	END IF;


	--bug: 8200511
	IF ( x_ccid <> l_setup_ccid) THEN
	      BEGIN

		SELECT 'Y' INTO l_insert_flag
			FROM FUN_INTER_ACCOUNTS_V
			WHERE FROM_LE_ID = p_from_le
			AND LEDGER_ID = p_ledger_id
			AND TO_LE_ID = p_to_le
			AND CCID = x_ccid
			AND TYPE = p_acct_type
			AND TRANS_BSV = p_from_bsv
			AND TP_BSV = p_to_bsv;
		 EXCEPTION
			WHEN NO_DATA_FOUND then
				l_insert_flag := 'N';
			WHEN OTHERS THEN
				l_insert_flag := 'Y';
	      END;
	      IF (l_insert_flag = 'N') THEN
			INSERT INTO FUN_INTER_ACCOUNTS_ADDL(FROM_LE_ID
				,      LEDGER_ID
				,      TO_LE_ID
				,      CCID
				,      TYPE
				,      START_DATE
				,      DEFAULT_FLAG
				,      OBJECT_VERSION_NUMBER
				,      CREATED_BY
				,      CREATION_DATE
				,      LAST_UPDATED_BY
				,      LAST_UPDATE_DATE
				,      LAST_UPDATE_LOGIN
				,      TRANS_BSV
				,      TP_BSV
				)
				VALUES(p_from_le
				,      p_ledger_id
				,      p_to_le
				,      x_ccid
				,      p_acct_type
				,      SYSDATE
				,      NULL
				,      1
				,      FND_GLOBAL.USER_ID
				,      SYSDATE
				,      FND_GLOBAL.USER_ID
				,      SYSDATE
				,      fnd_global.login_id
				,      p_from_bsv
				,      p_to_bsv
				);
		 END IF;
      END IF;

      IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
	                'fun.plsql.fun_bal_utils_grp.get_intercompany_account.get_new_recp_ccid',
			'Generating new reciprocal acc using ccid : '||l_setup_recp_ccid ||
                        'Bal BSV :'||p_to_bsv||'IC BSV :' ||p_from_bsv);
      END IF;

	  -- Call the procedure to generate the new account
      -- For eg if from the setup table we get back account 99-00-5670-00-99
      -- and if the from bsv is 01 and to bsv is 02, this api should return ccid
      -- for account 02-00-5670-00-01
      x_reciprocal_ccid := fun_bal_pkg.get_ccid (
                             ccid                       => l_setup_recp_ccid,
                             chart_of_accounts_id       => l_recp_coa,
                             bal_seg_val                => p_to_bsv,
                             intercompany_seg_val       => p_from_bsv,
                             bal_seg_column_number      => l_recp_bal_seg_num,
                             intercompany_column_number => l_recp_ic_seg_num,
                             gl_date                    => p_gl_date);

	SELECT count(1)
	INTO l_check_ccid
	FROM   gl_code_combinations cc
	WHERE  x_reciprocal_ccid = cc.code_combination_id
	   AND cc.detail_posting_allowed_flag = 'Y'
	   AND cc.enabled_flag = 'Y'
	   AND cc.summary_flag = 'N'
	   AND Nvl(cc.reference3,'N') = 'N'
	   AND cc.template_id IS NULL
	   AND (Trunc(p_gl_date) BETWEEN
			Trunc(Nvl(cc.start_date_active,p_gl_date)) AND
			Trunc(Nvl(cc.end_date_active,p_gl_date)));

	IF (l_check_ccid = 0)
	THEN
		FND_MESSAGE.SET_NAME('FUN', 'FUN_INTRA_CC_NOT_VALID');
		FND_MSG_PUB.Add;
		x_status :=  FND_API.G_RET_STS_ERROR;

	ELSE
		l_check_ccid := 0;
	END IF;

--bug: 8200511
	IF ( x_reciprocal_ccid <> l_setup_ccid) THEN
		BEGIN
		SELECT 'Y' INTO l_insert_flag
			FROM FUN_INTER_ACCOUNTS_V
			WHERE FROM_LE_ID = p_to_le
			AND LEDGER_ID = p_to_ledger_id
			AND TO_LE_ID = p_from_le
			AND CCID = x_reciprocal_ccid
			AND TYPE = l_recip_acct_type
			AND TRANS_BSV = p_to_bsv
			AND TP_BSV = p_from_bsv;
		 EXCEPTION
		       WHEN NO_DATA_FOUND then
				l_insert_flag := 'N';
			WHEN OTHERS THEN
				l_insert_flag := 'Y';
	      END;
	      IF (l_insert_flag = 'N') THEN
			INSERT INTO FUN_INTER_ACCOUNTS_ADDL(FROM_LE_ID
				,      LEDGER_ID
				,      TO_LE_ID
				,      CCID
				,      TYPE
				,      START_DATE
				,      DEFAULT_FLAG
				,      OBJECT_VERSION_NUMBER
				,      CREATED_BY
				,      CREATION_DATE
				,      LAST_UPDATED_BY
				,      LAST_UPDATE_DATE
				,      LAST_UPDATE_LOGIN
				,      TRANS_BSV
				,      TP_BSV
				)
				VALUES(p_to_le
				,      p_to_ledger_id
				,      p_from_le
				,      x_reciprocal_ccid
				,      l_recip_acct_type
				,      SYSDATE
				,      NULL
				,      1
				,      FND_GLOBAL.USER_ID
				,      SYSDATE
				,      FND_GLOBAL.USER_ID
				,      SYSDATE
				,      fnd_global.login_id
				,      p_to_bsv
				,      p_from_bsv
				);
		 END IF;
      END IF;

	ELSE
		-- If the Legal Entities are from different Ledgers, then the intercompany
		-- and balancing segment values are not switched.

		x_ccid := l_setup_ccid;
		x_reciprocal_ccid := l_setup_recp_ccid;
	END IF;

	-- Enhancement 7520196 End

  END IF;

  IF Nvl(x_ccid,0) <= 0
  THEN
      FND_MESSAGE.SET_NAME('FUN', 'FUN_INTRA_CC_NOT_CREATED');
      FND_MSG_PUB.Add;
      x_status :=  FND_API.G_RET_STS_ERROR;

  END IF;

    SELECT count(1)
	INTO l_check_ccid
	FROM   gl_code_combinations cc
	WHERE  x_ccid = cc.code_combination_id
	   AND cc.detail_posting_allowed_flag = 'Y'
	   AND cc.enabled_flag = 'Y'
	   AND cc.summary_flag = 'N'
	   AND Nvl(cc.reference3,'N') = 'N'
	   AND cc.template_id IS NULL
	   AND (Trunc(p_gl_date) BETWEEN
			Trunc(Nvl(cc.start_date_active,p_gl_date)) AND
			Trunc(Nvl(cc.end_date_active,p_gl_date)));

	IF (l_check_ccid = 0)
	THEN
		FND_MESSAGE.SET_NAME('FUN', 'FUN_INTRA_CC_NOT_VALID');
		FND_MSG_PUB.Add;
		x_status :=  FND_API.G_RET_STS_ERROR;

	ELSE
		l_check_ccid := 0;
	END IF;

	SELECT count(1)
	INTO l_check_ccid
	FROM   gl_code_combinations cc
	WHERE  x_reciprocal_ccid = cc.code_combination_id
	   AND cc.detail_posting_allowed_flag = 'Y'
	   AND cc.enabled_flag = 'Y'
	   AND cc.summary_flag = 'N'
	   AND Nvl(cc.reference3,'N') = 'N'
	   AND cc.template_id IS NULL
	   AND (Trunc(p_gl_date) BETWEEN
			Trunc(Nvl(cc.start_date_active,p_gl_date)) AND
			Trunc(Nvl(cc.end_date_active,p_gl_date)));

	IF (l_check_ccid = 0)
	THEN
		FND_MESSAGE.SET_NAME('FUN', 'FUN_INTRA_CC_NOT_VALID');
		FND_MSG_PUB.Add;
		x_status :=  FND_API.G_RET_STS_ERROR;

	ELSE
		l_check_ccid := 0;
	END IF;

   -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_utils_grp.get_intercompany_account.end', 'end');
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR
    THEN
       IF (FND_LOG.LEVEL_ERROR>= g_debug_level)
       THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
	                 'fun.plsql.fun_bal_pkg.get_intercompany_account.error',
			 SUBSTR(SQLERRM,1, 4000));
       END IF;

       x_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
       IF (FND_LOG.LEVEL_ERROR>= g_debug_level)
       THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
	                'fun.plsql.fun_bal_utils_grp.get_intercompany_account.unexpected_error_norm',
			SUBSTR(SQLCODE ||' : ' || SQLERRM,1, 4000));
       END IF;

       x_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS
    THEN
       IF (FND_LOG.LEVEL_ERROR>= g_debug_level)
       THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
	                 'fun.plsql.fun_bal_utils_grp.get_intercompany_account.unexpected_error_others',
 		          SUBSTR(SQLCODE ||' : ' || SQLERRM,1, 4000));
       END IF;

       IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
          FND_MSG_PUB.Add_Exc_Msg(g_package_name, l_api_name);
       END IF;

       x_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data  => x_msg_data);

END get_intercompany_account;

/* ----------------------------------------------------------------------------
--	API name 	: FUN_BAL_UTILS_GRP.get_intracompany_account
--	Type		: Group
--	Pre-reqs	: None.
--	Function	: Given a transacting and trading Balancing segment value, the
--                the procedure returns the intracompany credit and debit
--                account
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--              p_init_msg_list	            IN VARCHAR2 Optional
--              p_ledger_id                 IN NUMBER   Required
--              p_from_le                   IN NUMBER   Optional
--              p_source                    IN VARCHAR2 Optional
--                  If not provided, source of 'Other' will be used to derive
--                  the account
--              p_category                  IN VARCHAR2 Optional
--                  If not provided, category of 'Other' will be used to derive
--                  the account
--              p_from_bsv                  IN VARCHAR2 Required
--              p_to_bsv                    IN VARCHAR2 Required
--              p_gl_date                   IN DATE     Required
--              p_acct_type                 IN VARCHAR2 Required
--                  Account type would be 'D'ebit or 'C'redit
--
--	OUT		:	x_status                    VARCHAR2
--              x_msg_count                 NUMBER
--              x_msg_data                  VARCHAR2
--              x_ccid                      VARCHAR2   CCID requested
--              x_reciprocal_ccid           VARCHAR2   Reciprocal CCID
--                   Eg. If debit account ccid is requested for BSV1 => BSV2
--                   x_reciprocal_ccid will contain the credit account for
--                   BSV2 => BSV1
--
--	Version	: Current version	1.0
--			  Previous version 	1.0
--			  Initial version 	1.0
------------------------------------------------------------------------------*/
PROCEDURE get_intracompany_account (p_api_version       IN     NUMBER,
                                    p_init_msg_list	    IN	   VARCHAR2,
                                    p_ledger_id         IN     NUMBER,
                                    p_from_le           IN     NUMBER,
                                    p_source            IN     VARCHAR2,
                                    p_category          IN     VARCHAR2,
                                    p_dr_bsv            IN     VARCHAR2,
                                    p_cr_bsv            IN     VARCHAR2,
                                    p_gl_date           IN     DATE,
                                    p_acct_type         IN     VARCHAR2,
                                    x_status            IN OUT NOCOPY VARCHAR2,
                                    x_msg_count         IN OUT NOCOPY NUMBER,
                                    x_msg_data          IN OUT NOCOPY VARCHAR2,
                                    x_ccid              IN OUT NOCOPY NUMBER ,
                                    x_reciprocal_ccid   IN OUT NOCOPY NUMBER)
IS

CURSOR c_get_template (p_ledger_id     NUMBER,
                       p_le_id         NUMBER,
                       p_source_name   VARCHAR2,
                       p_category_name VARCHAR2)
IS
SELECT  NVL((SELECT opts.template_id
             FROM  fun_balance_options opts
             WHERE opts.ledger_id        = p_ledger_id
             AND   Nvl(opts.le_id,-99)   = Nvl(p_le_id,-99)
             AND   opts.je_source_name   = p_source_name
             AND   opts.je_category_name = p_category_name
             AND   opts.status_flag      = 'Y'),
      NVL((SELECT opts.template_id
             FROM  fun_balance_options opts
             WHERE opts.ledger_id        = p_ledger_id
             AND   Nvl(opts.le_id,-99)   = Nvl(p_le_id,-99)
             AND   opts.je_source_name   = p_source_name
             AND   opts.je_category_name = 'Other'
             AND   opts.status_flag      = 'Y'),
      NVL((SELECT opts.template_id
             FROM  fun_balance_options opts
             WHERE opts.ledger_id        = p_ledger_id
             AND   Nvl(opts.le_id,-99)   = Nvl(p_le_id,-99)
             AND   opts.je_source_name   = 'Other'
             AND   opts.je_category_name = p_category_name
             AND   opts.status_flag      = 'Y'),
      (SELECT opts.template_id
             FROM  fun_balance_options opts
             WHERE opts.ledger_id        = p_ledger_id
             AND   Nvl(opts.le_id,-99)   = Nvl(p_le_id,-99)
             AND   opts.je_source_name   = 'Other'
             AND   opts.je_category_name = 'Other'
             AND   opts.status_flag      = 'Y')))) template_id
  From Dual;

CURSOR c_get_ccid (p_template_id     NUMBER,
                   p_dr_bsv          VARCHAR2,
                   p_cr_bsv          VARCHAR2,
                   p_acct_type       VARCHAR2)
IS
SELECT  NVL((SELECT DECODE (p_acct_type, 'D', accts.dr_ccid, 'C', cr_ccid)
             FROM  fun_balance_accounts accts
             WHERE accts.template_id     = p_template_id
             AND   accts.dr_bsv          = p_dr_bsv
             AND   accts.cr_bsv          = p_cr_bsv),
      NVL((SELECT DECODE (p_acct_type, 'D', accts.dr_ccid, 'C', cr_ccid)
             FROM  fun_balance_accounts accts
             WHERE accts.template_id     = p_template_id
             AND   accts.dr_bsv          = p_dr_bsv
             AND   accts.cr_bsv          = 'OTHER1234567890123456789012345'),
      NVL((SELECT DECODE (p_acct_type, 'D', accts.dr_ccid, 'C', cr_ccid)
             FROM  fun_balance_accounts accts
             WHERE accts.template_id     = p_template_id
             AND   accts.dr_bsv          = 'OTHER1234567890123456789012345'
             AND   accts.cr_bsv          = p_cr_bsv),
      (SELECT DECODE (p_acct_type, 'D', accts.dr_ccid, 'C', cr_ccid)
             FROM  fun_balance_accounts accts
             WHERE accts.template_id     = p_template_id
             AND   accts.dr_bsv          = 'OTHER1234567890123456789012345'
             AND   accts.cr_bsv          = 'OTHER1234567890123456789012345')))) ccid
  From Dual;

  l_api_name         CONSTANT VARCHAR2(30)   := 'Get_Intracompany_Account';
  l_api_version      CONSTANT NUMBER         := 1.0;
  l_return_status    VARCHAR2(1);
  l_from_le_id       NUMBER ;
  l_recip_acct_type  VARCHAR2(1);
  l_template_id      NUMBER;
  l_source           gl_je_sources.je_source_name%TYPE;
  l_category         gl_je_categories.je_category_name%TYPE;

  l_setup_ccid       NUMBER;
  l_setup_recp_ccid  NUMBER;
  l_coa              NUMBER;
  l_dummy            NUMBER;
  l_ic_seg_num       NUMBER;
  l_bal_seg_num      NUMBER;
  -- Bug: 7368523
  l_dr_bsv	     FUN_BALANCE_ACCOUNTS.DR_BSV%TYPE;
  l_cr_bsv	     FUN_BALANCE_ACCOUNTS.CR_BSV%TYPE;
  l_check_ccid   NUMBER;
BEGIN

  l_check_ccid := 0;
  -- Bug 7193385 Start
  IF (p_acct_type = 'C')
  THEN
    l_dr_bsv := p_cr_bsv;
	l_cr_bsv := p_dr_bsv;
  ELSE
    l_dr_bsv := p_dr_bsv;
    l_cr_bsv := p_cr_bsv;
  END IF;
  -- Bug 7193385 End

  -- variable p_validation_level is not used .
  g_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_utils_grp.Get_Intracompany_Account.begin', 'begin');
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_package_name )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
	  FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_status := FND_API.G_RET_STS_SUCCESS;

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'fun.plsql.fun_bal_utils_grp.get_intracompany_account.get_template',
             'Fetching the template id');

  END IF;

  l_source   := Nvl(p_source, 'Other');
  l_category := Nvl(p_category, 'Other');

  -- Rules of precedence to find template id. Look for  ..
  -- 1)  Source , Category
  -- 2)  Source , 'Other'
  -- 3)  'Other', Category
  -- 4)  'Other', 'Other'

  OPEN c_get_template (p_ledger_id     => p_ledger_id,
                       p_le_id         => p_from_le,
                       p_source_name   => l_source,
                       p_category_name => l_category);
  FETCH c_get_template  INTO l_template_id;
  CLOSE c_get_template;

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
             'fun.plsql.fun_bal_utils_grp.get_intracompany_account.got_template',
             'Template id is '||l_template_id );
  END IF;

  IF l_template_id IS NULL
  THEN
      FND_MESSAGE.SET_NAME('FUN', 'FUN_INTRA_RULE_NOT_ASSIGNED');
      FND_MSG_PUB.Add;
      x_status :=  FND_API.G_RET_STS_ERROR;
  END IF;

  IF x_status = FND_API.G_RET_STS_SUCCESS
  THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
		                'fun.plsql.fun_bal_utils_grp.get_intracompany_account.get_ccid',
						'Fetching the  ccid');
      END IF;

      -- Now get the debit or credit account.
      -- Rules of precedence to find ccid. Look for  ..
      -- 1)  Dr BSV , Cr BSV
      -- 2)  Dr BSV , 'Other'
      -- 3)  'Other', Cr BSV
      -- 4)  'Other', 'Other'
      OPEN c_get_ccid (p_template_id     => l_template_id,
                       p_dr_bsv          => l_dr_bsv,
                       p_cr_bsv          => l_cr_bsv,
                       p_acct_type       => p_acct_type);
      FETCH  c_get_ccid INTO l_setup_ccid;
      CLOSE  c_get_ccid ;

      IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
		                'fun.plsql.fun_bal_utils_grp.get_intracompany_account.got_ccid',
				'Fetched the  ccid : '|| l_setup_ccid);
      END IF;

      -- Now get the reciprocal account
      IF p_acct_type = 'D'
      THEN
          l_recip_acct_type := 'C';
      ELSE
          l_recip_acct_type := 'D';
      END IF;

      IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
		                'fun.plsql.fun_bal_utils_grp.get_intracompany_account.get_recip_ccid',
				'Fetching the reciprocal ccid');
      END IF;

	  -- Bug 7409706: For Intracompany Rule
	  --  Debit BSV     Credit BSV     Debit Accoun    Credit Account
	  -- 01                  02                01.XXX.02       02.XXX.01
	  -- 02                  01                02.YYY.01        01.YYY.02
	  -- Id ccid = 01.XXX.02, then reciprocal_ccid = 02.XXX.01 and not 02.YYY.01
      OPEN c_get_ccid (p_template_id     => l_template_id,
                       p_dr_bsv          => l_dr_bsv,
                       p_cr_bsv          => l_cr_bsv,
                       p_acct_type       => l_recip_acct_type);
      FETCH  c_get_ccid INTO l_setup_recp_ccid;
      CLOSE  c_get_ccid ;

      IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
		                'fun.plsql.fun_bal_utils_grp.get_intracompany_account.got_recip_ccid',
				'Fetched the reciprocal ccid : ' || l_setup_recp_ccid);
      END IF;

      -- Now we need to generate the new accounts by replacing the intercompany
      -- segments and the balancing segments
      -- First find out the segment numbers for the Balancing segment
      OPEN c_get_seg_num(p_ledger_id,
                        'GL_BALANCING');
      FETCH c_get_seg_num INTO l_bal_seg_num,
                               l_coa;
      CLOSE c_get_seg_num;

      -- Next find out the segment numbers for the Intercompany segment
      OPEN c_get_seg_num(p_ledger_id,
                        'GL_INTERCOMPANY');
      FETCH c_get_seg_num INTO l_ic_seg_num,
                               l_dummy;
      CLOSE c_get_seg_num;

      IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
	                'fun.plsql.fun_bal_utils_grp.get_intracompany_account.get_new_ccid',
			'Generating new acc using ccid : '||l_setup_ccid ||
                        'Bal BSV :'||p_dr_bsv||'IC BSV :' ||p_cr_bsv);
      END IF;

      -- Call the procedure to generate the new account
      -- For eg if from the setup table we get back account 99-00-4350-00-99
      -- and if the dr bsv is 01 and cr bsv is 02, this api should return ccid
      -- for account 01-00-4350-00-02
      x_ccid := fun_bal_pkg.get_ccid (
                             ccid                       => l_setup_ccid,
                             chart_of_accounts_id       => l_coa,
                             bal_seg_val                => p_dr_bsv,
                             intercompany_seg_val       => p_cr_bsv,
                             bal_seg_column_number      => l_bal_seg_num,
                             intercompany_column_number => l_ic_seg_num,
                             gl_date                    => p_gl_date);

      IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
	                'fun.plsql.fun_bal_utils_grp.get_intracompany_account.get_new_recp_ccid',
			'Generating new reciprocal acc using ccid : '||l_setup_recp_ccid ||
                        'Bal BSV :'||p_cr_bsv||'IC BSV :' ||p_dr_bsv);
      END IF;

      -- Call the procedure to generate the new account
      -- For eg if from the setup table we get back account 99-00-5670-00-99
      -- and if the dr bsv is 01 and cr bsv is 02, this api should return ccid
      -- for account 02-00-5670-00-01
      x_reciprocal_ccid := fun_bal_pkg.get_ccid (
                             ccid                       => l_setup_recp_ccid,
                             chart_of_accounts_id       => l_coa,
                             bal_seg_val                => p_cr_bsv,
                             intercompany_seg_val       => p_dr_bsv,
                             bal_seg_column_number      => l_bal_seg_num,
                             intercompany_column_number => l_ic_seg_num,
                             gl_date                    => p_gl_date);

  END IF;

  IF Nvl(x_ccid,0) <= 0
  THEN
      FND_MESSAGE.SET_NAME('FUN', 'FUN_INTRA_CC_NOT_CREATED');
      FND_MSG_PUB.Add;
      x_status :=  FND_API.G_RET_STS_ERROR;
  END IF;

	SELECT count(1)
	INTO l_check_ccid
	FROM   gl_code_combinations cc
	WHERE  x_ccid = cc.code_combination_id
	   AND cc.detail_posting_allowed_flag = 'Y'
	   AND cc.enabled_flag = 'Y'
	   AND cc.summary_flag = 'N'
	   AND Nvl(cc.reference3,'N') = 'N'
	   AND cc.template_id IS NULL
	   AND (Trunc(p_gl_date) BETWEEN
			Trunc(Nvl(cc.start_date_active,p_gl_date)) AND
			Trunc(Nvl(cc.end_date_active,p_gl_date)));

	IF (l_check_ccid = 0)
	THEN
		FND_MESSAGE.SET_NAME('FUN', 'FUN_INTRA_CC_NOT_VALID');
		FND_MSG_PUB.Add;
		x_status :=  FND_API.G_RET_STS_ERROR;
	ELSE
		l_check_ccid := 0;
	END IF;

	SELECT count(1)
	INTO l_check_ccid
	FROM   gl_code_combinations cc
	WHERE  x_reciprocal_ccid = cc.code_combination_id
	   AND cc.detail_posting_allowed_flag = 'Y'
	   AND cc.enabled_flag = 'Y'
	   AND cc.summary_flag = 'N'
	   AND Nvl(cc.reference3,'N') = 'N'
	   AND cc.template_id IS NULL
	   AND (Trunc(p_gl_date) BETWEEN
			Trunc(Nvl(cc.start_date_active,p_gl_date)) AND
			Trunc(Nvl(cc.end_date_active,p_gl_date)));

	IF (l_check_ccid = 0)
	THEN
		FND_MESSAGE.SET_NAME('FUN', 'FUN_INTRA_CC_NOT_VALID');
		FND_MSG_PUB.Add;
		x_status :=  FND_API.G_RET_STS_ERROR;
	ELSE
		l_check_ccid := 0;
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_utils_grp.Get_Intracompany_Account.end', 'end');
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR
    THEN
       IF (FND_LOG.LEVEL_ERROR>= g_debug_level)
       THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
	                 'fun.plsql.fun_bal_pkg.Get_Intracompany_Account.error',
			 SUBSTR(SQLERRM,1, 4000));
       END IF;

       x_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
       IF (FND_LOG.LEVEL_ERROR>= g_debug_level)
       THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
	                'fun.plsql.fun_bal_utils_grp.Get_Intracompany_Account.unexpected_error_norm',
			SUBSTR(SQLCODE ||' : ' || SQLERRM,1, 4000));
       END IF;

       x_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS
    THEN
       IF (FND_LOG.LEVEL_ERROR>= g_debug_level)
       THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
	                 'fun.plsql.fun_bal_utils_grp.Get_Intracompany_Account.unexpected_error_others',
                          SUBSTR(SQLCODE ||' : ' || SQLERRM,1, 4000));
       END IF;

       IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg(g_package_name, l_api_name);
       END IF;

       x_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data  => x_msg_data);

END  get_intracompany_account;

END FUN_BAL_UTILS_GRP;

/
