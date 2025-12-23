import Testing
import SwiftData
import Foundation
@testable import WhatThePuck

@Suite("SwiftData Integration Tests")
struct SwiftDataIntegrationTests {

    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: Shot.self, Bean.self, configurations: config)
    }

    @Test("fetching shot by PersistentIdentifier preserves bean relationship")
    @MainActor
    func fetchShotByIdPreservesBeanRelationship() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let bean = Bean(name: "Test Espresso", roaster: "Local Roaster")
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )

        context.insert(bean)
        context.insert(shot)
        try context.save()

        let shotId = shot.persistentModelID

        let fetchedShot = context.model(for: shotId) as? Shot

        #expect(fetchedShot != nil)
        #expect(fetchedShot?.bean.name == "Test Espresso")
        #expect(fetchedShot?.bean.roaster == "Local Roaster")
    }

    @Test("accessing bean relationship after fetch does not crash")
    @MainActor
    func accessBeanRelationshipAfterFetch() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let bean = Bean(name: "Ethiopian", roaster: "Counter Culture")
        let shot = Shot(
            doseGrams: 17.5,
            yieldGrams: 35.0,
            timeSeconds: 300,
            grindSetting: 12,
            notes: "Fruity and bright",
            bean: bean
        )

        context.insert(bean)
        context.insert(shot)
        try context.save()

        let descriptor = FetchDescriptor<Shot>()
        let fetchedShots = try context.fetch(descriptor)

        #expect(fetchedShots.count == 1)

        let fetchedShot = fetchedShots[0]
        let beanId = fetchedShot.bean.id
        let beanName = fetchedShot.bean.name
        let beanDisplayName = fetchedShot.bean.displayName

        #expect(beanId == bean.id)
        #expect(beanName == "Ethiopian")
        #expect(beanDisplayName == "Ethiopian - Counter Culture")
    }

    @Test("model fetched by id can have its bean relationship modified")
    @MainActor
    func modifyBeanRelationshipOnFetchedModel() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let originalBean = Bean(name: "Original Bean", roaster: "Original Roaster")
        let newBean = Bean(name: "New Bean", roaster: "New Roaster")
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: originalBean
        )

        context.insert(originalBean)
        context.insert(newBean)
        context.insert(shot)
        try context.save()

        let shotId = shot.persistentModelID

        let fetchedShot = context.model(for: shotId) as? Shot
        #expect(fetchedShot?.bean.name == "Original Bean")

        fetchedShot?.bean = newBean
        try context.save()

        let refetchedShot = context.model(for: shotId) as? Shot
        #expect(refetchedShot?.bean.name == "New Bean")
    }

    @Test("multiple shots with same bean maintain relationship integrity")
    @MainActor
    func multipleShotsWithSameBeanMaintainRelationship() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let bean = Bean(name: "House Blend", roaster: "Local Cafe")

        let shot1 = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        let shot2 = Shot(
            doseGrams: 18.5,
            yieldGrams: 38.0,
            timeSeconds: 290,
            grindSetting: 14,
            bean: bean
        )

        context.insert(bean)
        context.insert(shot1)
        context.insert(shot2)
        try context.save()

        let descriptor = FetchDescriptor<Shot>(sortBy: [SortDescriptor(\.doseGrams)])
        let fetchedShots = try context.fetch(descriptor)

        #expect(fetchedShots.count == 2)
        #expect(fetchedShots[0].bean.id == fetchedShots[1].bean.id)
        #expect(fetchedShots[0].bean.name == "House Blend")
        #expect(fetchedShots[1].bean.name == "House Blend")
    }

    @Test("fetching shot from fresh context by id works correctly")
    @MainActor
    func fetchFromFreshContextById() throws {
        let container = try makeContainer()

        let shotId: PersistentIdentifier

        let insertContext = ModelContext(container)
        let bean = Bean(name: "Test Bean", roaster: "Test Roaster")
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        insertContext.insert(bean)
        insertContext.insert(shot)
        try insertContext.save()
        shotId = shot.persistentModelID

        let fetchContext = ModelContext(container)
        let fetchedShot = fetchContext.model(for: shotId) as? Shot

        #expect(fetchedShot != nil)
        #expect(fetchedShot?.bean.name == "Test Bean")
        #expect(fetchedShot?.doseGrams == 18.0)
    }
}
