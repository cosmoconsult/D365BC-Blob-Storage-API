codeunit 89150 "AZBSAT API Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        Constants: Codeunit "AZBSAT Constants";
        OperationFailedErr: Label 'Operation "%1" failed. Status Code: %2', Comment = '%1 = Operation, %2 = Status Code';

    trigger OnRun()
    begin

    end;

    local procedure GetContainerName(): Text
    begin
        Any.SetSeed(Random(5000));
        exit(Any.AlphabeticText(Any.IntegerInRange(5, 20)));
    end;

    local procedure GetListOfContainerNames(var ContainerNames: List of [Text])
    var
        MaxItems: Integer;
        i: Integer;
    begin
        Clear(ContainerNames);
        Any.SetSeed(Random(5000));
        MaxItems := Any.IntegerInRange(2, 5);
        for i := 1 to MaxItems do
            ContainerNames.Add(GetContainerName());
    end;

    local procedure WaitForCleanAccount()
    var
        Container: Record "AZBSA Container";
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
        WaitMiliSeconds: Integer;
        WaitedMiliseconds: Integer;
    begin
        WaitMiliSeconds := 250;
        repeat
            Container.Reset();
            Container.DeleteAll();

            Clear(RequestObject);
            Constants.InitializeSharedKeyAuthorization(RequestObject);
            Constants.InitializeRequest(RequestObject);
            API.ListContainers(RequestObject, Container, false);
            if not Container.IsEmpty() then begin
                Sleep(WaitMiliSeconds);
                WaitedMiliseconds += WaitMiliSeconds;
            end;
        until Container.IsEmpty() or (WaitedMiliseconds > 60000); // Max: 1 Minute
    end;

    [Test]
    procedure TestCreateContainer()
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
        ContainerName: Text;
    begin
        // [SCENARIO] A new containter is created in the Storage Account

        // [GIVEN] A Container Name        
        ContainerName := GetContainerName();

        // [GIVEN] A Storage Account exists
        Constants.InitializeSharedKeyAuthorization(RequestObject);
        Constants.InitializeRequest(RequestObject, ContainerName);

        // [THEN] Create the Container in the Storage Account
        API.CreateContainer(RequestObject);
        Assert.AreEqual(RequestObject.GetHttpResponseIsSuccessStatusCode(), true, StrSubstNo(OperationFailedErr, 'Create Container', RequestObject.GetHttpResponseStatusCode()));
    end;

    [Test]
    procedure TestDeleteContainerWithoutLease()
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
        ContainerName: Text;
    begin
        // [SCENARIO] An existing containter is deleted from the Storage Account

        // [GIVEN] A Container Name
        ContainerName := GetContainerName();

        // [GIVEN] A Storage Account exists
        Constants.InitializeSharedKeyAuthorization(RequestObject);
        Constants.InitializeRequest(RequestObject, ContainerName);

        // [THEN] Create the Container in the Storage Account
        API.CreateContainer(RequestObject);
        Assert.AreEqual(RequestObject.GetHttpResponseIsSuccessStatusCode(), true, StrSubstNo(OperationFailedErr, 'Create Container', RequestObject.GetHttpResponseStatusCode()));

        Clear(RequestObject);
        Constants.InitializeSharedKeyAuthorization(RequestObject);
        Constants.InitializeRequest(RequestObject, ContainerName);
        API.DeleteContainer(RequestObject);
        Assert.AreEqual(RequestObject.GetHttpResponseIsSuccessStatusCode(), true, StrSubstNo(OperationFailedErr, 'Delete Container', RequestObject.GetHttpResponseStatusCode()));
    end;

    [Test]
    procedure TestListContainers()
    var
        Container: Record "AZBSA Container";
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
        ContainerNames: List of [Text];
        ContainerName: Text;
        Count1: Integer;
        Count2: Integer;
    begin
        // [SCENARIO] Existing containters are listed from the Storage Account
        WaitForCleanAccount();

        // [GIVEN] A list of Container Names
        GetListOfContainerNames(ContainerNames);

        // [GIVEN] A Storage Account exists
        Constants.InitializeSharedKeyAuthorization(RequestObject);
        Constants.InitializeRequest(RequestObject);

        // [THEN] Create the Containers in the Storage Account
        foreach ContainerName in ContainerNames do begin
            RequestObject.SetContainerName(ContainerName);
            API.CreateContainer(RequestObject);
            Assert.AreEqual(RequestObject.GetHttpResponseIsSuccessStatusCode(), true, StrSubstNo(OperationFailedErr, 'Create Container', RequestObject.GetHttpResponseStatusCode()));
        end;

        Clear(RequestObject);
        Constants.InitializeSharedKeyAuthorization(RequestObject);
        Constants.InitializeRequest(RequestObject);
        API.ListContainers(RequestObject, Container, false);
        Count1 := Container.Count();
        Count2 := ContainerNames.Count();
        Assert.AreEqual(RequestObject.GetHttpResponseIsSuccessStatusCode(), true, StrSubstNo(OperationFailedErr, 'List Container', RequestObject.GetHttpResponseStatusCode()));
        Assert.AreEqual(Count1, Count2, 'Number of returned Containers does not match the ones created.');
    end;
}