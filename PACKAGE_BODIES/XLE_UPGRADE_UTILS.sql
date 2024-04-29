--------------------------------------------------------
--  DDL for Package Body XLE_UPGRADE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_UPGRADE_UTILS" AS
--$Header: xleupgutilb.pls 120.4 2006/04/17 06:41:54 akonatha ship $

G_PKG_NAME      CONSTANT  varchar2(30) := 'XLE_UPGRADE_UTILS_PKG';
G_FILE_NAME		CONSTANT  varchar2(30) := 'XLEPDLCB.pls';

PROCEDURE Get_default_legal_context
     ( x_return_status      OUT NOCOPY  VARCHAR2,
       x_msg_count          OUT NOCOPY  NUMBER,
       x_msg_data           OUT NOCOPY  VARCHAR2,
       p_org_id             IN          NUMBER,
       x_dlc                OUT NOCOPY  NUMBER )
    IS

 cursor check_org_id(p_org_Id IN NUMBER) is
 SELECT o.organization_id
 FROM hr_all_organization_units o,
      hr_organization_information o2,
      hr_organization_information o3
WHERE o.organization_id = o2.organization_id
 AND o.organization_id = o3.organization_id
 AND o3.organization_id = o2.organization_id
 AND o2.org_information_context || '' = 'CLASS'
 AND o3.org_information_context = 'Operating Unit Information'
 AND o2.org_information1 = 'OPERATING_UNIT'
 AND o2.org_information2 = 'Y'
 AND o.organization_id = p_org_id;


 cursor get_sob_id(p_org_id IN NUMBER) is
 SELECT to_number(o3.org_information3)
FROM hr_organization_information o3,
     hr_all_organization_units o,
     hr_organization_information o2
   WHERE o.organization_id = o2.organization_id
   AND o.organization_id = o3.organization_id
   AND o3.organization_id = o2.organization_id
   AND o2.org_information_context || '' = 'CLASS'
   AND o3.org_information_context = 'Operating Unit Information'
   AND o2.org_information1 = 'OPERATING_UNIT'
   AND o2.org_information2 = 'Y'
   AND o.organization_id = p_org_id;

 cursor acct_env_type(l_sob_id IN NUMBER) is select accounting_env_type from xle_sob_interface where set_of_books_id = l_sob_id;

 cursor def_legal_context(l_sob_id IN VARCHAR2) is select legal_entity_Id from xle_le_sob_interface where set_of_books_id = l_sob_id;

 cursor check_le(p_org_Id IN NUMBER) is select legal_entity_id from xle_le_ou_interface where organization_id = p_org_id;

 cursor check_le_mapped(p_org_id IN NUMBER) is
select O3.org_information2
from
    HR_ALL_ORGANIZATION_UNITS O,
    HR_ORGANIZATION_INFORMATION O2,
    HR_ORGANIZATION_INFORMATION O3
where
    O.organization_id=p_org_id
    AND O.ORGANIZATION_ID = O2.ORGANIZATION_ID
    AND O.ORGANIZATION_ID = O3.ORGANIZATION_ID
    AND O2.ORG_INFORMATION_CONTEXT = 'CLASS'
    AND O3.ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
    AND O2.ORG_INFORMATION1 = 'OPERATING_UNIT'
    AND O2.ORG_INFORMATION2 = 'Y'
 and exists(select le.legal_entity_id from xle_le_interface le where le.legal_entity_id = O3.org_information2);

 cursor le_bsv(l_sob_id IN NUMBER) is select legal_entity_id from  xle_le_bsv_interface where set_of_books_id = l_sob_id and rownum = 1;
   l_api_name varchar2(30):= 'Get_default_context';
   l_org_id             NUMBER;
   l_sob_id	        NUMBER;
   l_legal_entity_id	NUMBER;
   l_acct_env_type      VARCHAR2(30);
   l_def_legal_context  NUMBER := NULL;
   l_mapped_ou			NUMBER := NULL;
   l_bsv_le_id			NUMBER :=NULL;
   l_le_mapped		    NUMBER :=NULL;

BEGIN

 --Check if org_id passed exists in hr_operating_units

OPEN check_org_id(p_org_Id);
 FETCH check_org_id into l_org_id;
IF check_org_id%NOTFOUND THEN
RAISE FND_API.G_EXC_ERROR;
END IF;
CLOSE check_org_Id;

--Get set_of_books_id from hr_operating_units

OPEN get_sob_id(p_org_id);
FETCH get_sob_id into l_sob_id;
IF get_sob_id%NOTFOUND THEN
RAISE FND_API.G_EXC_ERROR;
END IF;
CLOSE get_sob_id;



--Get accounting_env_type from xle_sob_interface

OPEN acct_env_type(l_sob_id);
FETCH acct_env_type into l_acct_env_type;
IF acct_env_type%NOTFOUND THEN
RAISE FND_API.G_EXC_ERROR;
END IF;
CLOSE acct_env_type;


IF l_acct_env_type = 'EXCLUSIVE' THEN

      OPEN def_legal_context(l_sob_id);
      fetch def_legal_context into l_def_legal_context;
      IF def_legal_context%NOTFOUND  THEN
      RAISE FND_API.G_EXC_ERROR;
      END IF;
      x_dlc:=l_def_legal_context;
      CLOSE def_legal_context;

ELSIF

      l_acct_env_type = 'SHARED' THEN

      OPEN check_le(p_org_id);
      FETCH check_le into l_mapped_ou;
      IF check_le%NOTFOUND THEN
      l_mapped_ou := NULL;
      ELSE
      x_dlc:= l_mapped_ou;
      END IF;
      CLOSE check_le;

      OPEN check_le_mapped(p_org_id);
      fetch check_le_mapped into l_le_mapped;
      IF check_le_mapped%NOTFOUND THEN
      l_le_mapped := NULL;
      --RAISE FND_API.G_EXC_ERROR;
      ELSE
      x_dlc := l_le_mapped;
      END IF;
      CLOSE check_le_mapped;
--END IF;



      IF (l_mapped_ou is NULL and l_le_mapped is NULL) THEN

      OPEN le_bsv(l_sob_id);
      FETCH le_bsv into l_bsv_le_id;
      IF le_bsv%NOTFOUND THEN
      RAISE FND_API.G_EXC_ERROR;
      ELSE
      x_dlc := l_bsv_le_id;
      END IF;
      CLOSE le_bsv;
      END IF;

END IF;

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MSG_PUB.count_and_get(p_count  =>  x_msg_count,
                                     p_data => x_msg_data );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count  =>  x_msg_count,
                                p_data => x_msg_data );
      WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level
	  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
	FND_MSG_PUB.Add_Exc_Msg
          (G_FILE_NAME,
	   G_PKG_NAME,
           l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_count  =>  x_msg_count,
                                p_data => x_msg_data );

END;
END;


/
