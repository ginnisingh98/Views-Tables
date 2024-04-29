--------------------------------------------------------
--  DDL for Package Body QP_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PARTY_MERGE_PKG" AS
/* $Header: QPXPMRGB.pls 120.1.12010000.2 2009/04/24 11:20:37 smbalara ship $ */

/***********************************************************************
   Procedure to Merge those qualifier_attr_value's in QP_QUALIFIERS which
   reference Party_Id or Party_Site_Id. To be called by TCA when Parties
   or Party Sites are merged.
***********************************************************************/

Procedure Merge_Qualifiers(p_entity_name             IN  VARCHAR2,
                           p_from_id                 IN  NUMBER,
                           p_to_id                   OUT NOCOPY /* file.sql.39 change */ NUMBER,
                           p_from_fk_id              IN  NUMBER,
                           p_to_fk_id                IN  NUMBER,
                           p_parent_entity_name      IN  VARCHAR2,
                           p_batch_id                IN  NUMBER,
                           p_batch_party_id          IN  NUMBER,
                           x_return_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_temp_date   DATE;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_temp_date  := trunc(sysdate);

  --If Parent getting transferred, then do nothing. Set Merged To Id
  --to the same as Merged From Id and Return

  IF p_from_fk_id = p_to_fk_id
  THEN
    p_to_id := p_from_id;
    RETURN;
  END IF;


  --If Parent has changed (Parent is getting Merged), then transfer the
  --dependent record to the new parent. Before transferring check if a
  --similar record exists on the new parent. If a duplicate exists then
  --do not transfer and return the id of the duplicate record as the
  --Merged To Id.

  IF p_from_fk_id <> p_to_fk_id
  THEN

    /*Party_Id references are merged when:
      When qualifier_context  = 'ASOPARTYINFO' AND
      qualifier_attribute = 'QUALIFIER_ATTRIBUTE1' --Customer Party
      OR
      qualifier_context  = 'CUSTOMER' AND
      qualifier_attribute = 'QUALIFIER_ATTRIBUTE16' --Party Id
      OR
      qualifier_context  = 'CUSTOMER_GROUP' AND
      qualifier_attribute = 'QUALIFIER_ATTRIBUTE3' --Buying Groups
      OR
      qualifier_context  = 'PARTY' AND
      qualifier_attribute = 'QUALIFIER_ATTRIBUTE1' --Supplier
      OR
      qualifier_context  = 'PARTY' AND
      qualifier_attribute = 'QUALIFIER_ATTRIBUTE2' --Buyer
    */

    /*Party_Site_Id references are merged when:
      When qualifier_context  = 'ASOPARTYINFO' AND
      qualifier_attribute = 'QUALIFIER_ATTRIBUTE10' --Ship To Party Site
      OR
      qualifier_context  = 'ASOPARTYINFO' AND
      qualifier_attribute = 'QUALIFIER_ATTRIBUTE11' --Bill To Party Site
      OR
      a.qualifier_context  = 'CUSTOMER' AND
      a.qualifier_attribute = 'QUALIFIER_ATTRIBUTE17' --Ship To Party Site
      OR
      a.qualifier_context  = 'CUSTOMER' AND
      a.qualifier_attribute = 'QUALIFIER_ATTRIBUTE18' --Invoice To Party Site
    */
    BEGIN
      SELECT a.qualifier_id
      INTO   p_to_id
      FROM   qp_qualifiers a
      WHERE  a.qualifier_attr_value = to_char(p_to_fk_id)
      AND    trunc(l_temp_date) between nvl(trunc(start_date_active), trunc(l_temp_date)) and
             nvl(trunc(end_date_active), trunc(l_temp_date))
      AND   (a.qualifier_context,
             a.qualifier_attribute,
             nvl(a.list_header_id, -1),
             nvl(a.list_line_id, -1),
             nvl(qualifier_rule_id, -1),
             a.qualifier_grouping_no) IN
                      (SELECT b.qualifier_context, b.qualifier_attribute,
                              nvl(b.list_header_id, -1),
                              nvl(b.list_line_id, -1),
                              nvl(qualifier_rule_id, -1),
                              b.qualifier_grouping_no
                       FROM   qp_qualifiers b
                       WHERE  b.qualifier_id = p_from_id
                       AND    b.qualifier_id <> a.qualifier_id)
      AND rownum = 1;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_to_id := NULL;
    END;

    IF p_to_id IS NULL THEN /* Duplicate Does Not Exist. Therefore Transfer*/

      UPDATE qp_qualifiers
      SET    qualifier_attr_value = to_char(p_to_fk_id),
             last_update_date = hz_utility_pub.last_update_date,
             last_updated_by = hz_utility_pub.user_id,
             last_update_login = hz_utility_pub.last_update_login,
             request_id = hz_utility_pub.request_id,
             program_application_id = hz_utility_pub.program_application_id,
             program_id = hz_utility_pub.program_id,
             program_update_date = sysdate
      WHERE  qualifier_id = p_from_id;

      RETURN;

    END IF; --If p_to_id is null


    IF p_to_id IS NOT NULL THEN /* Duplicate Exists. Therefore Merge and set
                                   the status of the entity as Merged. The
                                   Merged_To Id is the duplicate found on the
                                   new parent */
-- Start for bug 8399342 / 8210994 - deleting instead of end dating duplicate qualifiers
 /*     UPDATE qp_qualifiers
      SET    qualifier_attr_value = to_char(p_to_fk_id),
             end_date_active = sysdate,
             last_update_date = hz_utility_pub.last_update_date,
             last_updated_by = hz_utility_pub.user_id,
             last_update_login = hz_utility_pub.last_update_login,
             request_id = hz_utility_pub.request_id,
             program_application_id = hz_utility_pub.program_application_id,
             program_id = hz_utility_pub.program_id,
             program_update_date = sysdate
      WHERE  qualifier_id = p_from_id;
 */
      DELETE qp_qualifiers
      WHERE qualifier_id = p_from_id;
-- End for bug 8399342 / 8210994 - deleting instead of end dating duplicate qualifiers
      RETURN;

    END IF; --If p_to_id is not null


  END IF; --If p_from_fk_id and p_to_fk_id are different

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR','HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Merge_Qualifiers;

END QP_PARTY_MERGE_PKG;

/
