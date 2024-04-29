--------------------------------------------------------
--  DDL for Package Body FPA_VALIDATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_VALIDATION_PVT" as
 /* $Header: FPAVVALB.pls 120.6 2006/03/20 19:10:16 appldev noship $ */

 G_PKG_NAME    CONSTANT VARCHAR2(200) := 'FPA_VALIDATION_PVT';
 G_APP_NAME    CONSTANT VARCHAR2(3)   :=  FPA_UTILITIES_PVT.G_APP_NAME;
 G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';
 L_API_NAME    CONSTANT VARCHAR2(35)  := 'VALIDATION';


 TYPE Validation_Rec_Type is RECORD
      (Validation_Type     VARCHAR2(30),
       Severity            VARCHAR2(1),
       Object_Id           NUMBER,
       Object_type         VARCHAR2(30)
           );

   TYPE Validation_Tbl_Type IS TABLE OF Validation_Rec_Type
   INDEX BY BINARY_INTEGER;

   is_Validation            BOOLEAN := FALSE;
   Validations_Count        NUMBER := 0;
   Validations              Validation_Tbl_Type;

   G_VALIDATION_SET      VARCHAR2(30);
   G_HEADER_ID           NUMBER;

PROCEDURE Create_Validation_Line
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_validation_set        IN              VARCHAR2,
    p_validation_lines_rec  IN              FPA_VALIDATION_LINES_REC,
    x_validation_id         OUT NOCOPY      NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Create_Validation_Line';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
----------------------------------------------------------------------------
  l_flag                   VARCHAR2(1);
  l_validation_lines_rec   FPA_VALIDATION_LINES_REC := p_validation_lines_rec;

  CURSOR OBJ_VAL_TYPE_CSR (VALIDATION_SET      IN VARCHAR2,
                           OBJ_VALIDATION_TYPE IN VARCHAR2) IS
         SELECT 'T'
         FROM FPA_LOOKUPS_V
         WHERE LOOKUP_TYPE = VALIDATION_SET
         AND LOOKUP_CODE   = OBJ_VALIDATION_TYPE;

  CURSOR HDR_VAL_TYPE_CSR (VALIDATION_SET      IN VARCHAR2) IS
         SELECT 'T'
         FROM FPA_LOOKUPS_V
         WHERE LOOKUP_TYPE = VALIDATION_SET;

  CURSOR SEV_TYPE_CSR (SEV_CODE      IN VARCHAR2) IS
         SELECT 'T'
         FROM FPA_LOOKUPS_V
         WHERE LOOKUP_TYPE = 'FPA_SEVERITY_TYPES'
         AND LOOKUP_CODE = SEV_CODE;
 BEGIN

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              p_msg_log       => 'Entering Fpa_Validation_Pvt.Create_Validation_Line',
              x_return_status => x_return_status);

    if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
         l_msg_log := 'start_activity';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
         l_msg_log := 'start_activity';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;

    open  obj_val_type_csr(p_validation_set, l_validation_lines_rec.validation_type);
    fetch obj_val_type_csr into l_flag;
    close obj_val_type_csr;

    if(l_flag is null or l_flag <> FND_API.G_TRUE) then
        open  hdr_val_type_csr(p_validation_set);
        fetch hdr_val_type_csr into l_flag;
        close hdr_val_type_csr;
    end if;

    if(l_flag is null or l_flag <> FND_API.G_TRUE) then
        Fpa_Utilities_Pvt.Set_Message(
                          p_msg_name     => 'FPA_INVALID_VALIDATION',
                          p_token1       => 'TYPE',
                          p_token1_value => p_validation_set);
        raise Fpa_Utilities_Pvt.G_EXCEPTION_ERROR;
    end if;

    l_flag := null;
    if(l_validation_lines_rec.severity is not null) then
        open  sev_type_csr(l_validation_lines_rec.severity);
        fetch sev_type_csr into l_flag;
        close sev_type_csr;
        if(l_flag is null or l_flag <> FND_API.G_TRUE) then
            Fpa_Utilities_Pvt.Set_Message(
                              p_msg_name     => 'FPA_INVALID_SEVERITY_TYPE',
                              p_token1       => 'TYPE',
                              p_token1_value => l_validation_lines_rec.severity);
            raise Fpa_Utilities_Pvt.G_EXCEPTION_ERROR;
        end if;
    else
        l_validation_lines_rec.severity := 'I';
    end if;


    select fpa_validation_lines_s.nextval into
    l_validation_lines_rec.validation_id from dual;
    x_validation_id  := l_validation_lines_rec.validation_id;
    l_validation_lines_rec.created_by        := FND_GLOBAL.USER_ID;
    l_validation_lines_rec.creation_date     := SYSDATE;
    l_validation_lines_rec.last_updated_by   := FND_GLOBAL.USER_ID;
    l_validation_lines_rec.last_update_date  := SYSDATE;
    l_validation_lines_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

    INSERT INTO FPA_VALIDATION_LINES(
         validation_id,
         header_id,
         object_id,
         object_type,
         validation_type,
         message_id,
         severity,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login)
    VALUES (
         l_validation_lines_rec.validation_id,
         l_validation_lines_rec.header_id,
         l_validation_lines_rec.object_id,
         l_validation_lines_rec.object_type,
         l_validation_lines_rec.validation_type,
         l_validation_lines_rec.message_id,
         l_validation_lines_rec.severity,
         l_validation_lines_rec.created_by,
         l_validation_lines_rec.creation_date,
         l_validation_lines_rec.last_updated_by,
         l_validation_lines_rec.last_update_date,
         l_validation_lines_rec.last_update_login);

    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);

EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END Create_Validation_line;


FUNCTION Add_Validation
(
    p_validation       IN VARCHAR2,
    p_severity_code    IN VARCHAR2,
    p_object_id        IN NUMBER,
    p_object_type      IN VARCHAR2
) RETURN BOOLEAN IS

BEGIN
    if(is_Validation) then
        Validations_Count := Validations_Count + 1;
        Validations(Validations_Count).validation_type := p_validation;
        Validations(Validations_Count).object_id   := p_object_id;
        Validations(Validations_Count).object_type := p_object_type;
        Validations(Validations_Count).severity    := p_severity_code;
    end if;
    if(Validations_Count >= 10) then
        Close_Validations;
    end if;
    return is_Validation;

EXCEPTION
      when OTHERS then
        return is_Validation;
END Add_Validation;

PROCEDURE Initialize IS

BEGIN

    is_Validation := TRUE;
    Validations.DELETE;
    Validations_Count := 0;

EXCEPTION
      when OTHERS then
        null;
END Initialize;

PROCEDURE UnInitialize IS

BEGIN

    is_Validation := FALSE;
    Validations.DELETE;
    Validations_Count := 0;

EXCEPTION
      when OTHERS then
        null;
END UnInitialize;


PROCEDURE Close_Validations IS

-- standard parameters
  l_return_status          VARCHAR2(1);
  l_init_msg_list          VARCHAR2(1)           := 'F';
  l_api_name               CONSTANT VARCHAR2(30) := 'Close_Validations';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
----------------------------------------------------------------------------

i INTEGER;
l_validation_lines_rec  FPA_VALIDATION_LINES_REC;
l_validation_id         NUMBER;
l_exists VARCHAR2(1) := FND_API.G_FALSE;

CURSOR CHECK_VALIDATION_LINES(
            P_VALIDATIONS_TYPE     IN VARCHAR2,
            P_OBJECT_HEADER_ID    IN NUMBER,
            P_OBJECT_ID           IN NUMBER,
            P_OBJECT_TYPE         IN VARCHAR2) IS
    SELECT 'T'
    FROM  FPA_VALIDATION_LINES FPA
    WHERE
    FPA.VALIDATION_TYPE = P_VALIDATIONS_TYPE
    AND FPA.HEADER_ID = P_OBJECT_HEADER_ID
    AND FPA.OBJECT_ID = P_OBJECT_ID
    AND FPA.OBJECT_TYPE = P_OBJECT_TYPE;

BEGIN

    if (Validations.count = 0) THEN
        return;
    end if;

    FPA_UTILITIES_PVT.START_ACTIVITY(
            p_api_name      => l_api_name,
            p_pkg_name      => G_PKG_NAME,
            p_init_msg_list => l_init_msg_list,
            p_msg_log       => 'Entering '||G_PKG_NAME||'.'||l_api_name);

    for i in validations.first .. Validations.last
    loop

        open CHECK_VALIDATION_LINES(
                P_VALIDATIONS_TYPE => Validations(i).validation_type,
                P_OBJECT_HEADER_ID => G_HEADER_ID,
                P_OBJECT_ID        => Validations(i).object_id,
                P_OBJECT_TYPE      => Validations(i).object_type);
        fetch CHECK_VALIDATION_LINES into l_exists;
        close CHECK_VALIDATION_LINES;

        if(l_exists is not null and l_exists = FND_API.G_TRUE) then
            return;
        end if;

        l_validation_lines_rec := null;
        l_validation_lines_rec.header_id        := G_HEADER_ID;
        l_validation_lines_rec.object_id        := Validations(i).object_id;
        l_validation_lines_rec.object_type      := Validations(i).object_type;
        l_validation_lines_rec.validation_type  := Validations(i).validation_type;
        l_validation_lines_rec.message_id       := Validations(i).validation_type;
        l_validation_lines_rec.severity         := Validations(i).severity;

        Create_Validation_Line(
               p_api_version          => l_api_version,
               p_init_msg_list        => l_init_msg_list,
               p_validation_set       => G_VALIDATION_SET,
               p_validation_lines_rec => l_validation_lines_rec,
               x_validation_id        => l_validation_id,
               x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);

        if (l_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
             l_msg_log := 'Close_Validations';
             raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
        elsif (l_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
             l_msg_log := 'Close_Validations';
             raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
        end if;

    end loop;

    Initialize;

    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => l_msg_count,
                    x_msg_data     => l_msg_data);

EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         l_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => l_msg_count,
            x_msg_data  => l_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         l_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => l_msg_count,
            x_msg_data  => l_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         l_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => l_msg_count,
            x_msg_data  => l_msg_data,
            p_api_type  => G_API_TYPE);
END Close_Validations;



FUNCTION Check_Error_Level (p_object_id   IN NUMBER,
                            p_object_type IN VARCHAR2,
                            p_error_level IN VARCHAR2)
RETURN BOOLEAN
IS

-- standard parameters
  l_return_status          VARCHAR2(1);
  l_init_msg_list          VARCHAR2(1)           := 'F';
  l_api_name               CONSTANT VARCHAR2(30) := 'Check_Error_Level';
  l_msg_log                VARCHAR2(2000)        := null;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
----------------------------------------------------------------------------

l_exists VARCHAR2(1) := FND_API.G_FALSE;

CURSOR CHECK_SEVERITY(
            P_OBJECT_ID           IN NUMBER,
            P_OBJECT_TYPE         IN VARCHAR2,
            P_SEVERITY            IN VARCHAR2) IS
    SELECT 'T'
    FROM  FPA_VALIDATION_LINES HDR, FPA_VALIDATION_LINES OBJ
    WHERE
    HDR.VALIDATION_TYPE = G_VALIDATION_SET
    AND HDR.OBJECT_ID   = G_HEADER_ID
    AND OBJ.HEADER_ID   = HDR.OBJECT_ID
    AND OBJ.OBJECT_ID   = P_OBJECT_ID
    AND OBJ.OBJECT_TYPE = P_OBJECT_TYPE
    AND OBJ.SEVERITY    = P_SEVERITY;

BEGIN

    if (Validations.count > 0) THEN
        Close_Validations;
    end if;

    FPA_UTILITIES_PVT.START_ACTIVITY(
            p_api_name      => l_api_name,
            p_pkg_name      => G_PKG_NAME,
            p_init_msg_list => l_init_msg_list,
            p_msg_log       => 'Entering '||G_PKG_NAME||'.'||l_api_name);

    open CHECK_SEVERITY(
            P_OBJECT_ID    => P_OBJECT_ID,
            P_OBJECT_TYPE  => P_OBJECT_TYPE,
            P_SEVERITY     => P_ERROR_LEVEL);
    fetch CHECK_SEVERITY into l_exists;
    close CHECK_SEVERITY;

    if(l_exists is not null and l_exists = FND_API.G_TRUE) then
        return true;
    else
        return false;
    end if;

   FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => l_msg_count,
                    x_msg_data     => l_msg_data);

EXCEPTION

      when OTHERS then
         l_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => l_msg_count,
            x_msg_data  => l_msg_data,
            p_api_type  => G_API_TYPE);
END Check_Error_Level;


FUNCTION Count_Validations RETURN NUMBER
IS
BEGIN

    RETURN Validations_Count;

END Count_Validations;


FUNCTION Validation RETURN BOOLEAN
IS
BEGIN

    RETURN is_Validation;

END Validation;


PROCEDURE Check_Lock_Resource(
          p_api_version          IN         NUMBER,
          p_init_msg_list        IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_header_object_id     IN         NUMBER,
          p_header_object_type   IN         VARCHAR2,
          p_validations_type     IN         FPA_VALIDATION_LINES.VALIDATION_TYPE%TYPE,
          x_resource_status      OUT        NOCOPY INTEGER,
          x_resource_id          OUT        NOCOPY FPA_VALIDATION_LINES.VALIDATION_ID%TYPE,
          x_return_status        OUT        NOCOPY      VARCHAR2,
          x_msg_count            OUT        NOCOPY      NUMBER,
          x_msg_data             OUT        NOCOPY      VARCHAR2)
IS

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Check_Lock_Resource';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_init_msg_list          VARCHAR2(1) := 'F';
  l_msg_log                VARCHAR2(2000)        := null;

----------------------------------------------------------------------------
  E_Resource_Busy                EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

  CURSOR lock_csr  IS
      SELECT VALIDATION_ID
          FROM FPA_VALIDATION_LINES
      WHERE OBJECT_ID = P_HEADER_OBJECT_ID
            AND OBJECT_TYPE = P_HEADER_OBJECT_TYPE
            AND VALIDATION_TYPE  = P_VALIDATIONS_TYPE
      FOR UPDATE OF LAST_UPDATE_DATE NOWAIT;

    l_header_id         INTEGER := null;

  BEGIN

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    FPA_UTILITIES_PVT.START_ACTIVITY(
            p_api_name      => l_api_name,
            p_pkg_name      => G_PKG_NAME,
            p_init_msg_list => l_init_msg_list,
            p_msg_log       => 'Entering '||G_PKG_NAME||'.'||l_api_name);

    BEGIN
      OPEN  lock_csr;
      FETCH lock_csr INTO l_header_id;
      CLOSE lock_csr;

    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        x_resource_status := G_RESOURCE_BUSY;
        x_resource_id     := l_header_id;
        FPA_UTILITIES_PVT.END_ACTIVITY(
                        p_api_name     => l_api_name,
                        p_pkg_name     => G_PKG_NAME,
                        p_msg_log      => null,
                        x_msg_count    => x_msg_count,
                        x_msg_data     => x_msg_data);
        return;
    END;

    if(l_header_id is null) then
        x_resource_status := G_NO_RESOURCE_REC;
        x_resource_id     := l_header_id;
        FPA_UTILITIES_PVT.END_ACTIVITY(
                        p_api_name     => l_api_name,
                        p_pkg_name     => G_PKG_NAME,
                        p_msg_log      => null,
                        x_msg_count    => x_msg_count,
                        x_msg_data     => x_msg_data);
        return;
    end if;

    x_resource_status := -1;
    x_resource_id     :=  l_header_id;
    return;

  EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

  END Check_Lock_Resource;


PROCEDURE Validate
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_validation_set        IN              VARCHAR2,
    p_header_object_id      IN              NUMBER,
    p_header_object_type    IN              VARCHAR2,
    p_line_projects_tbl     IN              PROJECT_ID_TBL_TYPE,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Validate';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
----------------------------------------------------------------------------

  l_res_status             INTEGER := -1;
  l_validation_lines_rec   FPA_VALIDATION_LINES_REC;
  l_validation_id          NUMBER;
  l_header_id              NUMBER;

 BEGIN

    DBMS_TRANSACTION.SAVEPOINT(L_API_NAME || G_API_TYPE);

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              p_msg_log       => 'Entering Fpa_Validation_Pvt.Validate',
              x_return_status => x_return_status);

    if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
         l_msg_log := 'start_activity';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
         l_msg_log := 'start_activity';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;

    Initialize;

    G_VALIDATION_SET   := p_validation_set;
    G_HEADER_ID        := p_header_object_id;
    Check_Lock_Resource(
              p_api_version        => p_api_version,
              p_init_msg_list      => p_init_msg_list,
              p_header_object_id   => G_HEADER_ID,
              p_header_object_type => p_header_object_type,
              p_validations_type   => G_VALIDATION_SET,
              x_resource_status    => l_res_status,
              x_resource_id        => l_header_id,
              x_return_status      => x_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data);

    if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
         l_msg_log := 'Validate.Check_Lock_Resource';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
         l_msg_log := 'validate.Check_Lock_Resource';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;

    if(l_res_status = G_NO_RESOURCE_REC) then
    -- no header record

        l_validation_lines_rec.header_id        := null;
        l_validation_lines_rec.object_id        := G_HEADER_ID;
        l_validation_lines_rec.object_type      := p_header_object_type;
        l_validation_lines_rec.validation_type  := G_VALIDATION_SET;

        Create_Validation_Line(
               p_api_version          => p_api_version,
               p_init_msg_list        => p_init_msg_list,
               p_validation_set       => G_VALIDATION_SET,
               p_validation_lines_rec => l_validation_lines_rec,
               x_validation_id        => l_validation_id,
               x_return_status        => x_return_status,
               x_msg_count            => x_msg_count,
               x_msg_data             => x_msg_data);

        if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
             l_msg_log := 'Validations';
             raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
        elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
             l_msg_log := 'Validations';
             raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
        end if;

        -- following commit and new savepoint not required
        -- if header record can be created before transaction starts
        commit;
        DBMS_TRANSACTION.SAVEPOINT(L_API_NAME || G_API_TYPE);

        Check_Lock_Resource(
                 p_api_version        => p_api_version,
                 p_init_msg_list      => p_init_msg_list,
                 p_header_object_id   => G_HEADER_ID,
                 p_header_object_type => p_header_object_type,
                 p_validations_type   => G_VALIDATION_SET,
                 x_resource_status    => l_res_status,
                 x_resource_id        => l_header_id,
                 x_return_status      => x_return_status,
                 x_msg_count          => x_msg_count,
                 x_msg_data           => x_msg_data);

        if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
             l_msg_log := 'Validate.Check_Lock_Resource';
             raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
        elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
             l_msg_log := 'validate.Check_Lock_Resource';
             raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
        end if;

    elsif(l_res_status = G_RESOURCE_BUSY) then

            Fpa_Utilities_Pvt.Set_Message(
                              p_app_name     =>  G_APP_NAME,
                              p_msg_name     => 'FPA_USER_VALIDATION_IN_PROGRESS');
            raise Fpa_Utilities_Pvt.G_EXCEPTION_ERROR;

    end if;

    DELETE FROM FPA_VALIDATION_LINES FL
    WHERE FL.HEADER_ID IN (
          SELECT OBJECT_ID FROM FPA_VALIDATION_LINES FH
          WHERE  FH.VALIDATION_TYPE = P_VALIDATION_SET
                 AND FH.OBJECT_TYPE = P_HEADER_OBJECT_TYPE
                 AND FH.OBJECT_ID   = P_HEADER_OBJECT_ID);

    Initialize;

    Fpa_Validation_Process_Pvt.Validate(
            p_api_version        => p_api_version,
            p_init_msg_list      => p_init_msg_list,
            p_validation_set     => p_validation_set,
            p_header_object_id   => p_header_object_id,
            p_header_object_type => p_header_object_type,
            p_line_projects_tbl  => p_line_projects_tbl,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data);

    Close_Validations;
    UnInitialize;

    UPDATE FPA_VALIDATION_LINES
    SET LAST_UPDATED_BY    = FND_GLOBAL.USER_ID,
        LAST_UPDATE_DATE   = SYSDATE,
        LAST_UPDATE_LOGIN  = FND_GLOBAL.LOGIN_ID
    WHERE VALIDATION_ID = L_HEADER_ID;


    if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
         l_msg_log := 'Validate';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
         l_msg_log := 'Validate';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);


EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         UnInitialize;
         DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(L_API_NAME || G_API_TYPE);

         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         UnInitialize;
         DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(L_API_NAME || G_API_TYPE);

         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         UnInitialize;
         DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(L_API_NAME || G_API_TYPE);

         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END Validate;

PROCEDURE Validate
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_validation_set        IN              VARCHAR2,
    p_header_object_id      IN              NUMBER,
    p_header_object_type    IN              VARCHAR2,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Validate';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
----------------------------------------------------------------------------
  l_projects_tbl           PROJECT_ID_TBL_TYPE;

 BEGIN

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              p_msg_log       => 'Entering Fpa_Validation_Pvt.Validate',
              x_return_status => x_return_status);

    if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
         l_msg_log := 'start_activity';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
         l_msg_log := 'start_activity';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;

    Validate(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        p_validation_set     => p_validation_set,
        p_header_object_id   => p_header_object_id,
        p_header_object_type => p_header_object_type,
        p_line_projects_tbl  => l_projects_tbl,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data);

    if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
         l_msg_log := 'Validate';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
         l_msg_log := 'Validate';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);


EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then

         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then

         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then

         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END Validate;


END FPA_VALIDATION_PVT;

/
