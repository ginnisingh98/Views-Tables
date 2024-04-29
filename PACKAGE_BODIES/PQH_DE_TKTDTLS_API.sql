--------------------------------------------------------
--  DDL for Package Body PQH_DE_TKTDTLS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_TKTDTLS_API" as
/* $Header: pqtktapi.pkb 115.1 2002/12/05 00:30:14 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_DE_TKTDTLS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Insert_TKT_DTLS >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_TKT_DTLS
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_TATIGKEIT_NUMBER              In  Varchar2  Default NULL
  ,P_DESCRIPTION                   In  Varchar2
  ,P_TATIGKEIT_DETAIL_ID           out nocopy Number
  ,p_object_version_number         out nocopy number) is
  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(72)    := g_package||'Insert_TKT_DTLS';
  l_object_Version_Number PQH_DE_TATIGKEIT_DETAILS.OBJECT_VERSION_NUMBER%TYPE;
  L_Effective_Date        Date;
  l_TATIGKEIT_DETAIL_ID   PQH_DE_TATIGKEIT_DETAILS.TATIGKEIT_DETAIL_ID%TYPE;


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Insert_TKT_DTLS;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --



  begin
   PQH_DE_TKTDTLS_BK1.Insert_TKT_DTLS_b
   (p_effective_date             => L_Effective_Date
   ,p_TATIGKEIT_NUMBER           => p_TATIGKEIT_NUMBER
   ,P_DESCRIPTION                => P_DESCRIPTION );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_TATIGKEIT_DETAILS'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
     pqh_tkt_ins.ins
    (p_effective_date               => l_Effective_date
    ,p_tatigkeit_number             => P_tatigkeit_number
    ,p_description                  => P_DESCRIPTION
    ,p_tatigkeit_detail_id          => l_tatigkeit_detail_id
    ,p_object_version_number        => l_OBJECT_VERSION_NUMBER
    );

  --
  -- Call After Process User Hook
  --
  begin


        PQH_DE_TKTDTLS_BK1.Insert_TKT_DTLS_a
           (p_effective_date             => L_Effective_Date
           ,p_TATIGKEIT_NUMBER           => p_TATIGKEIT_NUMBER
           ,P_DESCRIPTION                => P_DESCRIPTION
           ,P_TATIGKEIT_DETAIL_ID        => l_TATIGKEIT_DETAIL_ID
           ,p_object_version_number      => l_object_version_number);


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_TATIGKEIT_DETAILS'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  P_TATIGKEIT_DETAIL_ID     := l_TATIGKEIT_DETAIL_ID;
  p_object_version_number   := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Insert_TKT_DTLS;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_TATIGKEIT_DETAIL_ID    := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
    p_TATIGKEIT_DETAIL_ID    := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Insert_TKT_DTLS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Insert_TKT_DTLS;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_TKT_DTLS >--------------------------|
-- ----------------------------------------------------------------------------

procedure Update_TKT_DTLS
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_TATIGKEIT_NUMBER              In  Varchar2 Default hr_api.g_Varchar2
  ,P_DESCRIPTION                   In  Varchar2 Default hr_api.g_Varchar2
  ,P_TATIGKEIT_DETAIL_ID           In  Number
  ,p_object_version_number         in out nocopy number) Is

  l_proc  varchar2(72)      := g_package||'Update_TKT_DTLS';
  l_object_Version_Number   PQH_DE_TATIGKEIT_DETAILS.OBJECT_VERSION_NUMBER%TYPE := P_Object_version_Number;
  L_Effective_Date          Date;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_TKT_DTLS;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin


PQH_DE_TKTDTLS_BK2.Update_TKT_DTLS_b
           (p_effective_date             => L_Effective_Date
           ,p_TATIGKEIT_NUMBER           => p_TATIGKEIT_NUMBER
           ,P_DESCRIPTION                => P_DESCRIPTION
           ,P_TATIGKEIT_DETAIL_ID        => p_TATIGKEIT_DETAIL_ID
           ,p_object_version_number      => l_object_version_number);


 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TATIGKEIT_DETAILS'
        ,p_hook_type   => 'BP'
        );
  end;

pqh_tkt_upd.upd
  (p_effective_date               => l_Effective_Date
  ,p_tatigkeit_detail_id          => p_TATIGKEIT_DETAIL_ID
  ,p_object_version_number        => l_object_version_number
  ,p_tatigkeit_number             => p_TATIGKEIT_NUMBER
  ,p_description                  => P_DESCRIPTION  ) ;

--
--
  -- Call After Process User Hook
  --
  begin


 PQH_DE_TKTDTLS_BK2.Update_TKT_DTLS_a
           (p_effective_date             => L_Effective_Date
           ,p_TATIGKEIT_NUMBER           => p_TATIGKEIT_NUMBER
           ,P_DESCRIPTION                => P_DESCRIPTION
           ,P_TATIGKEIT_DETAIL_ID        => p_TATIGKEIT_DETAIL_ID
           ,p_object_version_number      => l_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TATIGKEIT_DETAILS'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --

  p_object_version_number  := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Update_TKT_DTLS;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
  p_object_version_number  := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Update_TKT_DTLS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_TKT_DTLS;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_TKT_DTLS>-----------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_TKT_DTLS
  (p_validate                      in     boolean  default false
  ,p_TATIGKEIT_DETAIL_ID           In     Number
  ,p_object_version_number         In     number) Is   --

  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_TKT_DTLS';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_TKT_DTLS;
  --
  -- Call Before Process User Hook
  --
  begin
  PQH_DE_TKTDTLS_BK3.Delete_TKT_DTLS_b
  (p_TATIGKEIT_DETAIL_Id           =>   p_TATIGKEIT_DETAIL_Id
  ,p_object_version_number         =>   p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TATIGKEIT_DETAILS'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Process Logic
  --
  pqh_tkt_del.del
  (p_tatigkeit_detail_id                    =>   p_TATIGKEIT_DETAIL_Id
  ,p_object_version_number                  =>   p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin

  PQH_DE_TKTDTLS_BK3.Delete_TKT_DTLS_a
  (p_TATIGKEIT_DETAIL_Id           =>   p_TATIGKEIT_DETAIL_Id
  ,p_object_version_number         =>   p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TATIGKEIT_DETAILS'
        ,p_hook_type   => 'AP');
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_TKT_DTLS;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_TKT_DTLS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_TKT_DTLS;

end PQH_DE_TKTDTLS_API;

/
