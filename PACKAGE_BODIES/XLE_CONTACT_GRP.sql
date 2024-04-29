--------------------------------------------------------
--  DDL for Package Body XLE_CONTACT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_CONTACT_GRP" AS
/* $Header: xlecontb.pls 120.0 2005/10/27 14:12:43 bsilveir noship $ */

FUNCTION concat_contact_roles (p_contact_party_id IN NUMBER,
                               p_le_etb_party_id  IN NUMBER)

RETURN VARCHAR2 IS

CURSOR  c_get_role IS
   SELECT lkup.meaning role_meaning
   FROM   xle_lookups lkup,
          xle_contact_legal_roles role
   WHERE  role.lookup_code = lkup.lookup_code
   AND    role.contact_party_id = p_contact_party_id
   AND    role.le_etb_party_id  = p_le_etb_party_id
   AND    role.lookup_type      = 'XLE_CONTACT_ROLE'
   AND    lkup.enabled_flag     = 'Y'
   AND    TRUNC(SYSDATE) BETWEEN Nvl(lkup.start_date_active,TRUNC(SYSDATE)) AND Nvl(Lkup.end_date_active,TRUNC(SYSDATE));

l_role_string     VARCHAR2(2000) := NULL;

TYPE string_tbl IS TABLE OF VARCHAR2(30);
l_roles_tbl   string_tbl;
l_max_rows    NUMBER;


BEGIN

    OPEN c_get_role;
    FETCH c_get_role BULK COLLECT INTO l_roles_tbl;
    CLOSE c_get_role;

    l_max_rows := l_roles_tbl.COUNT;

    FOR l_index IN 1..l_max_rows
    LOOP
        IF l_index > 10
        THEN
            EXIT;
        END IF;

        IF l_role_string IS NULL
        THEN
            l_role_string := l_roles_tbl(l_index);
        ELSE
            l_role_string := l_role_string || ', ' || l_roles_tbl(l_index);
        END IF;

    END LOOP;

    RETURN l_role_string;
END concat_contact_roles;


PROCEDURE end_contact_roles (p_contact_party_id  IN     NUMBER,
                             p_le_etb_party_id   IN     NUMBER,
                             p_commit            IN     VARCHAR2,
		             x_return_status     OUT NOCOPY VARCHAR2,
  		             x_msg_count         OUT NOCOPY NUMBER,
		             x_msg_data          OUT NOCOPY VARCHAR2)
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_le_etb_party_id IS NULL OR p_contact_party_id IS NULL
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data  := 'Mandatory parameters not passed to end_contact_roles';
    ELSE
        UPDATE xle_contact_legal_roles
        SET    effective_to = SYSDATE
        WHERE  contact_party_id = p_contact_party_id
        AND    le_etb_party_id  = p_le_etb_party_id
        AND    effective_to IS NULL;
    END IF;

    IF FND_API.To_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get (
                p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data);

END end_contact_roles;


END XLE_CONTACT_GRP;

/
