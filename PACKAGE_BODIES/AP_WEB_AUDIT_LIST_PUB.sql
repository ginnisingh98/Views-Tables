--------------------------------------------------------
--  DDL for Package Body AP_WEB_AUDIT_LIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_AUDIT_LIST_PUB" AS
/* $Header: apwpalab.pls 115.3 2004/07/01 07:47:40 jrautiai noship $ */

 /* =======================================================================
  | Global Data Types
  * ======================================================================*/

  G_PKG_NAME     CONSTANT VARCHAR2(30) := 'AP_WEB_AUDIT_LIST_PUB';

  G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
  G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
  G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
  G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
  G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
  G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

/*========================================================================
 | PUBLIC PROCEDUDE Audit_Employee
 |
 | DESCRIPTION
 |   This procedure adds a employee to the Internet Expenses automated
 |   audit list.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Public API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Standard API parameters
 |
 | PARAMETERS
 |   p_api_version      IN  Standard API paramater
 |   p_init_msg_list    IN  Standard API paramater
 |   p_commit           IN  Standard API paramater
 |   p_validation_level IN  Standard API paramater
 |   x_return_status    OUT Standard API paramater
 |   x_msg_count        OUT Standard API paramater
 |   x_msg_data         OUT Standard API paramater
 |   p_emp_rec          IN  Employee record containg criteria used to find a given employee
 |   p_audit_rec        IN  Audit record containg information about the record to be created
 |   x_auto_audit_id    OUT Identifier of the new record created, if multiple created returns -1.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 05-Dec-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE Audit_Employee(p_api_version      IN  NUMBER,
                         p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                         p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                         p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                         x_return_status    OUT NOCOPY VARCHAR2,
                         x_msg_count        OUT NOCOPY NUMBER,
                         x_msg_data         OUT NOCOPY VARCHAR2,
                         p_emp_rec          IN  Employee_Rec_Type,
                         p_audit_rec        IN  Audit_Rec_Type,
                         x_auto_audit_id    OUT NOCOPY NUMBER) IS

  l_api_name           CONSTANT VARCHAR2(30) := 'Change_Employee_Status';
  l_api_version        CONSTANT NUMBER       := 1.0;
  l_return_status      VARCHAR2(1);
  l_emp_rec            Employee_Rec_Type;
  l_audit_rec          Audit_Rec_Type;
  l_auto_audit_id      NUMBER;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT Change_Employee_Status_PVT;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
			             G_PKG_NAME) THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_emp_rec := p_emp_rec;
  l_audit_rec := p_audit_rec;

  -- Validate required input
  AP_WEB_AUDIT_LIST_VAL_PVT.Validate_Required_Input(l_emp_rec,
                                                    l_audit_rec,
                                                    l_return_status);

  -- If any errors happen abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Validate employee information
  AP_WEB_AUDIT_LIST_VAL_PVT.Validate_Employee_Info(l_emp_rec,
                                                   l_return_status);
  -- If any errors happen abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Validate audit information
  AP_WEB_AUDIT_LIST_VAL_PVT.Validate_Audit_Info(l_emp_rec,
                                                l_audit_rec,
                                                l_return_status);
  -- If any errors happen abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- If validations succesful, add employee to the audit list
  AP_WEB_AUDIT_LIST_PVT.process_entry(l_emp_rec,
                                      l_audit_rec,
                                      l_return_status,
                                      l_auto_audit_id);

  -- Set OUT values
  x_auto_audit_id  := l_auto_audit_id;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Change_Employee_Status_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE, p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Change_Employee_Status_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE, p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO Change_Employee_Status_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF FND_MSG_PUB.Check_Msg_Level THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE, p_count => x_msg_count, p_data  => x_msg_data);

END Audit_Employee;

/*========================================================================
 | PUBLIC PROCEDUDE Deaudit_Employee
 |
 | DESCRIPTION
 |   This procedure removes a employee from the Internet Expenses automated
 |   audit list.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Public API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Standard API parameters
 |
 | PARAMETERS
 |   p_api_version      IN  Standard API paramater
 |   p_init_msg_list    IN  Standard API paramater
 |   p_commit           IN  Standard API paramater
 |   p_validation_level IN  Standard API paramater
 |   x_return_status    OUT Standard API paramater
 |   x_msg_count        OUT Standard API paramater
 |   x_msg_data         OUT Standard API paramater
 |   p_emp_rec          IN  Employee record containg criteria used to find a given employee
 |   p_date_range_rec   IN  Record containg date range
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 29-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE Deaudit_Employee(p_api_version      IN  NUMBER,
                           p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                           p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                           p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                           x_return_status    OUT NOCOPY VARCHAR2,
                           x_msg_count        OUT NOCOPY NUMBER,
                           x_msg_data         OUT NOCOPY VARCHAR2,
                           p_emp_rec          IN  Employee_Rec_Type,
                           p_date_range_rec   IN  Date_Range_Type) IS

  l_api_name           CONSTANT VARCHAR2(30) := 'Remove_Employee_From_Audit';
  l_api_version        CONSTANT NUMBER       := 1.0;
  l_return_status      VARCHAR2(1);
  l_emp_rec            Employee_Rec_Type;
  l_date_range_rec     Date_Range_Type;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT Remove_Employee_From_Audit_PVT;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
			             G_PKG_NAME) THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_emp_rec := p_emp_rec;
  l_date_range_rec := p_date_range_rec;

  -- Validate required input
  AP_WEB_AUDIT_LIST_VAL_PVT.Validate_Required_Input(l_emp_rec,
                                                    l_date_range_rec,
                                                    l_return_status);

  -- If any errors happen abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Validate employee information
  AP_WEB_AUDIT_LIST_VAL_PVT.Validate_Employee_Info(l_emp_rec,
                                                   l_return_status);
  -- If any errors happen abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- If any errors happen abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- If validations succesful, add employee to the audit list
  AP_WEB_AUDIT_LIST_PVT.remove_entries(l_emp_rec,
                                       l_date_range_rec,
                                       l_return_status);

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Remove_Employee_From_Audit_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE, p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Remove_Employee_From_Audit_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE, p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO Remove_Employee_From_Audit_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF FND_MSG_PUB.Check_Msg_Level THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE, p_count => x_msg_count, p_data  => x_msg_data);

END Deaudit_Employee;

END AP_WEB_AUDIT_LIST_PUB;

/
