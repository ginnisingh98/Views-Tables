--------------------------------------------------------
--  DDL for Package Body ITG_ORGEFF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_ORGEFF_PVT" AS
/* ARCS: $Header: itgeffb.pls 115.5 2003/12/03 23:01:42 klai noship $
 * CVS:  itgeffb.pls,v 1.13 2002/12/23 21:20:30 ecoe Exp
 */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'ITG_OrgEff_PVT';

  CURSOR orgind_csr(
    p_doctyp VARCHAR2,
    p_pubsub VARCHAR2
  ) IS
    SELECT org_controlled
    FROM   itg_org_indicator
    WHERE  cln_doc_type  = p_doctyp
    AND    doc_direction = p_pubsub;

  /* Check the effectivity. */
  FUNCTION Check_Effective(
    p_organization_id  IN  NUMBER,
    p_cln_doc_type     IN  VARCHAR2,
    p_doc_direction    IN  VARCHAR2	/* 'P'ublish or 'S'ubscribe */
  ) RETURN BOOLEAN IS

    /* This query was the key to the effectivity defaulting (wildcard) scheme,
       of the sparse matrix scheme.  (It's a cool trick, which is why I am not
       deleting it).  Note that cln_doc_type is no longer allowed to be NULL.

    CURSOR orgeff_csr(
      p_orgid  NUMBER,
      p_doctyp VARCHAR2,
      p_pubsub VARCHAR2
    ) IS
      SELECT   start_date, end_date, effectivity_enabled
      FROM     itg_org_effectivity
      WHERE    (organization_id = p_orgid  OR organization_id IS NULL)
      AND      (cln_doc_type    = p_doctyp OR cln_doc_type    IS NULL)
      AND       doc_direction   = p_pubsub
      ORDER BY organization_id ASC,
               cln_doc_type    ASC;

       It is now replaced with the more direct query:

     */

    CURSOR orgeff_csr(
      p_orgid  NUMBER,
      p_doctyp VARCHAR2,
      p_pubsub VARCHAR2
    ) IS
      SELECT   start_date, end_date, effectivity_enabled
      FROM     itg_org_effectivity
      WHERE    NVL(organization_id, -1) = NVL(p_orgid, -1)
      AND      cln_doc_type    = p_doctyp
      AND      doc_direction   = p_pubsub;

    l_found  BOOLEAN;
    l_orgid  NUMBER;
    l_orgind itg_org_indicator.org_controlled%TYPE;
    l_orgeff orgeff_csr%ROWTYPE;
  BEGIN
    /* Check if effectivity restrictions are globally enabled. */
    /* TBD: add the site profile item ITG_ORG_EFFECTIVE ('Y'/'N'). */
    IF NVL(UPPER(FND_PROFILE.VALUE('ITG_ORG_EFFECTIVE')), 'N') <> 'Y' THEN
      ITG_Debug.msg('Effective: not profile enabled.');
      RETURN TRUE;
    END IF;

    /* Check if effectivity restrictions are enabled for this document type. */
    OPEN  orgind_csr(p_cln_doc_type, p_doc_direction);
    FETCH orgind_csr INTO l_orgind;
    l_found := orgind_csr%FOUND;
    CLOSE orgind_csr;
    IF NOT l_found THEN
      /* No effectivity record means non-effectivity controlled. */
      ITG_Debug.msg('Effective: non-effectivity controlled.');
      RETURN TRUE;
    END IF;

    /* Check the nitty-gritty itty-bitty effectivity. :) */
    l_orgid := p_organization_id;
    IF l_orgind <> FND_API.G_TRUE THEN
      l_orgid := NULL;
    END IF;
    OPEN  orgeff_csr(l_orgid, p_cln_doc_type, p_doc_direction);
    FETCH orgeff_csr INTO l_orgeff;
    l_found := orgeff_csr%FOUND;
    CLOSE orgeff_csr;
    /* In the older wildcard scheme, we wouldn't care if more records are
       available.  There shouldn't be any more now with the new query. */

    IF l_found THEN
      IF l_orgeff.effectivity_enabled = FND_API.G_TRUE THEN
        IF (l_orgeff.start_date IS NULL OR l_orgeff.start_date <= SYSDATE) AND
           (l_orgeff.end_date   IS NULL OR l_orgeff.end_date   >= SYSDATE) THEN
	  ITG_Debug.msg('Effective: all tests passed.');
	  RETURN TRUE;
	ELSE
	  ITG_Debug.msg('Not effective: date out of range');
	END IF;
      ELSE
        ITG_Debug.msg('Not effective: not enabled');
      END IF;
    ELSE
      ITG_Debug.msg('Not effective: no effectivity record.');
    END IF;
    RETURN FALSE;
  END Check_Effective;

  PROCEDURE Update_Effectivity(
    p_api_version      IN         NUMBER,
    p_init_msg_list    IN         VARCHAR2 := FND_API.G_FALSE,
    p_commit           IN         VARCHAR2 := FND_API.G_FALSE,
    p_validation_level IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,

    x_return_status    OUT NOCOPY VARCHAR2,           /* VARCHAR2(1) */
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,           /* VARCHAR2(2000) */

    p_organization_id  IN         NUMBER,
    p_cln_doc_type     IN         VARCHAR2,
    p_doc_direction    IN         VARCHAR2,
    p_start_date       IN         DATE      := NULL,
    p_end_date         IN         DATE      := NULL,
    p_effective        IN         VARCHAR2  := NULL
  ) IS
    l_api_name    CONSTANT VARCHAR2(30) := 'Update_Effectivity';
    l_api_version CONSTANT NUMBER       := 1.0;

    l_found	BOOLEAN;
    l_eff_id	NUMBER;
    l_dummy     itg_org_indicator.org_controlled%TYPE;
    l_count	NUMBER;
    l_flag      VARCHAR2(1);

    CURSOR existing_row_csr IS
      SELECT effectivity_id
      FROM   itg_org_effectivity
      WHERE  NVL(organization_id, -1) = NVL(p_organization_id, -1)
      AND    cln_doc_type             = p_cln_doc_type
      AND    doc_direction            = p_doc_direction;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
      SAVEPOINT Update_Effectivity_PVT;
      ITG_Debug.setup(
        p_reset     => TRUE,
        p_pkg_name  => G_PKG_NAME,
        p_proc_name => l_api_name);
      IF NOT FND_API.Compatible_API_Call(
          l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
      END IF;

      ITG_Debug.msg('UE', 'Top of procedure.');
      ITG_Debug.msg('UE', 'p_organization_id', p_organization_id);
      ITG_Debug.msg('UE', 'p_cln_doc_type',    p_cln_doc_type);
      ITG_Debug.msg('UE', 'p_doc_direction',   p_doc_direction);
      ITG_Debug.msg('UE', 'p_start_date',      p_start_date);
      ITG_Debug.msg('UE', 'p_end_date',        p_end_date);
      ITG_Debug.msg('UE', 'p_effective',       p_effective);

      IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN
        ITG_Debug.msg('UE', 'Validating input arguments.');

	IF p_cln_doc_type IS NULL THEN
	  l_count := 0;
	ELSE
	  SELECT count(1)
	  INTO   l_count
	  FROM   fnd_lookup_values
	  WHERE  lookup_type = 'CLN_COLLABORATION_DOC_TYPE'
	  AND    lookup_code = p_cln_doc_type
      AND    language = USERENV('LANG');
	END IF;

	IF l_count <> 1 THEN
	  ITG_MSG.invalid_argument('p_cln_doc_type', p_cln_doc_type);
	  RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF p_doc_direction <> 'P' AND p_doc_direction <> 'S' THEN
	  ITG_MSG.invalid_doc_direction(p_doc_direction);
	  RAISE FND_API.G_EXC_ERROR;
	END IF;

	OPEN  orgind_csr(p_cln_doc_type, p_doc_direction);
	FETCH orgind_csr INTO l_dummy;
	l_found := orgind_csr%FOUND;
	CLOSE orgind_csr;
	IF NOT l_found THEN
	  ITG_MSG.missing_orgind(p_cln_doc_type, p_doc_direction);
	  RAISE FND_API.G_EXC_ERROR;
	END IF;
      END IF;

      IF p_effective = FND_API.G_TRUE  OR
	 p_effective = FND_API.G_FALSE THEN
	l_flag := p_effective;
      ELSE
	l_flag := NULL;
      END IF;

      ITG_Debug.msg('UE', 'Looking for existing effectivity row.');
      OPEN  existing_row_csr;
      FETCH existing_row_csr INTO l_eff_id;
      l_found := existing_row_csr%FOUND;
      CLOSE existing_row_csr;

      IF l_found THEN
        ITG_Debug.msg('UE', 'Updating existing effectivity row.');
	DECLARE
        BEGIN
	  UPDATE itg_org_effectivity
	  SET    start_date          = p_start_date,
		 end_date            = p_end_date,
		 effectivity_enabled = NVL(l_flag, effectivity_enabled),
		 last_updated_by     = FND_GLOBAL.user_id,
		 last_update_date    = SYSDATE,
		 last_update_login   = FND_GLOBAL.login_id
	  WHERE  effectivity_id = l_eff_id;
	EXCEPTION
          WHEN NO_DATA_FOUND THEN
	     ITG_MSG.effectivity_update_fail(
	       p_organization_id, p_cln_doc_type, p_doc_direction, l_eff_id);
	     RAISE FND_API.G_EXC_ERROR;
	END;
      ELSE
        ITG_Debug.msg('UE', 'Inserting new effectivity row.');
        BEGIN
	  INSERT INTO itg_org_effectivity (
	    effectivity_id,
	    organization_id,
	    cln_doc_type,
	    doc_direction,
	    start_date,
	    end_date,
	    effectivity_enabled,
	    created_by,
	    creation_date,
	    last_updated_by,
	    last_update_date,
	    last_update_login
	  ) VALUES (
	    itg_org_effectivity_s.nextval,
	    p_organization_id,
	    p_cln_doc_type,
	    p_doc_direction,
	    p_start_date,
	    p_end_date,
	    NVL(l_flag, FND_API.G_TRUE),
	    FND_GLOBAL.user_id,
	    SYSDATE,
	    FND_GLOBAL.user_id,
	    SYSDATE,
	    FND_GLOBAL.login_id
	  );
	EXCEPTION
          WHEN NO_DATA_FOUND THEN
	     ITG_MSG.effectivity_insert_fail(
	       p_organization_id, p_cln_doc_type, p_doc_direction);
	     RAISE FND_API.G_EXC_ERROR;
	END;
      END IF;

      IF FND_API.To_Boolean(p_commit) THEN
        ITG_Debug.msg('UE', 'Committing work.');
	COMMIT WORK;
      END IF;
      ITG_Debug.msg('UE', 'Done.');

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Update_Effectivity_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
	ITG_Debug.add_error;
        ITG_Debug.msg('UE', 'EXCEPTION, checked error.', TRUE);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Update_Effectivity_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ITG_Debug.msg('UE', 'EXCEPTION, un-expected error.', TRUE);

      WHEN OTHERS THEN
        ROLLBACK TO Update_Effectivity_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	ITG_Debug.add_exc_error(G_PKG_NAME, l_api_name);
        ITG_Debug.msg('UE', 'EXCEPTION, other error.', TRUE);
    END;

    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);

  END Update_Effectivity;

END;

/
