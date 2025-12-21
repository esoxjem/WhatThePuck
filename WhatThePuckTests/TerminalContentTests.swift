import Testing
import Foundation
@testable import WhatThePuck

@Suite("Terminal Content Onboarding Tests")
struct TerminalContentOnboardingTests {

    @Test("onboarding without beans has two lines")
    func onboardingWithoutBeansTwoLines() {
        let content = TerminalContent.onboarding(hasBeans: false)
        #expect(content.lines.count == 2)
    }

    @Test("onboarding with beans has three lines")
    func onboardingWithBeansThreeLines() {
        let content = TerminalContent.onboarding(hasBeans: true)
        #expect(content.lines.count == 3)
    }

    @Test("onboarding first line is welcome message")
    func onboardingFirstLineIsWelcome() {
        let content = TerminalContent.onboarding(hasBeans: false)
        #expect(content.lines[0] == "Welcome to espresso hell.")
    }

    @Test("onboarding second line prompts to add beans")
    func onboardingSecondLinePromptsBeans() {
        let content = TerminalContent.onboarding(hasBeans: false)
        #expect(content.lines[1] == "Let's add your coffee beans.")
    }

    @Test("onboarding with beans includes ready message")
    func onboardingWithBeansIncludesReadyMessage() {
        let content = TerminalContent.onboarding(hasBeans: true)
        #expect(content.lines[2] == "We're ready to pull the first shot.")
    }

    @Test("onboarding character delay is 0.06")
    func onboardingCharacterDelay() {
        let content = TerminalContent.onboarding(hasBeans: false)
        #expect(content.characterDelay == 0.06)
    }
}

@Suite("Terminal Content Bean Context Tests")
struct TerminalContentBeanContextTests {

    @Test("bean context has three lines")
    func beanContextHasThreeLines() {
        let bean = Bean(name: "Ethiopian", roaster: "Onyx")
        let content = TerminalContent.beanContext(bean: bean)
        #expect(content.lines.count == 3)
    }

    @Test("first line shows bean display name")
    func firstLineShowsBeanDisplayName() {
        let bean = Bean(name: "Geisha", roaster: "Onyx Coffee Lab")
        let content = TerminalContent.beanContext(bean: bean)
        #expect(content.lines[0] == "Geisha - Onyx Coffee Lab loaded.")
    }

    @Test("first line shows only name when no roaster")
    func firstLineShowsOnlyNameWhenNoRoaster() {
        let bean = Bean(name: "House Blend", roaster: "")
        let content = TerminalContent.beanContext(bean: bean)
        #expect(content.lines[0] == "House Blend loaded.")
    }

    @Test("second line shows roast age when available")
    func secondLineShowsRoastAge() {
        let calendar = Calendar.current
        let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: Date.now)!
        let bean = Bean(name: "Test", roastDate: fiveDaysAgo)
        let content = TerminalContent.beanContext(bean: bean)
        #expect(content.lines[1] == "5 days off roast.")
    }

    @Test("second line shows roast level when no roast date")
    func secondLineShowsRoastLevel() {
        let bean = Bean(name: "Test", roastLevel: .dark, roastDate: nil)
        let content = TerminalContent.beanContext(bean: bean)
        #expect(content.lines[1] == "Dark roast.")
    }

    @Test("second line shows medium roast by default")
    func secondLineShowsMediumRoastByDefault() {
        let bean = Bean(name: "Test", roastDate: nil)
        let content = TerminalContent.beanContext(bean: bean)
        #expect(content.lines[1] == "Medium roast.")
    }

    @Test("third line prompts to pull shot")
    func thirdLinePromptsPullShot() {
        let bean = Bean(name: "Test")
        let content = TerminalContent.beanContext(bean: bean)
        #expect(content.lines[2] == "Pull your first shot.")
    }

    @Test("bean context character delay is 0.04")
    func beanContextCharacterDelay() {
        let bean = Bean(name: "Test")
        let content = TerminalContent.beanContext(bean: bean)
        #expect(content.characterDelay == 0.04)
    }
}

@Suite("Terminal Content Roast Info Tests")
struct TerminalContentRoastInfoTests {

    @Test("shows light roast level correctly")
    func showsLightRoastLevel() {
        let bean = Bean(name: "Test", roastLevel: .light, roastDate: nil)
        let content = TerminalContent.beanContext(bean: bean)
        #expect(content.lines[1] == "Light roast.")
    }

    @Test("shows medium roast level correctly")
    func showsMediumRoastLevel() {
        let bean = Bean(name: "Test", roastLevel: .medium, roastDate: nil)
        let content = TerminalContent.beanContext(bean: bean)
        #expect(content.lines[1] == "Medium roast.")
    }

    @Test("shows medium-dark roast level correctly")
    func showsMediumDarkRoastLevel() {
        let bean = Bean(name: "Test", roastLevel: .mediumDark, roastDate: nil)
        let content = TerminalContent.beanContext(bean: bean)
        #expect(content.lines[1] == "Medium-Dark roast.")
    }

    @Test("shows dark roast level correctly")
    func showsDarkRoastLevel() {
        let bean = Bean(name: "Test", roastLevel: .dark, roastDate: nil)
        let content = TerminalContent.beanContext(bean: bean)
        #expect(content.lines[1] == "Dark roast.")
    }

    @Test("roast age takes priority over roast level")
    func roastAgeTakesPriority() {
        let calendar = Calendar.current
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: Date.now)!
        let bean = Bean(name: "Test", roastLevel: .dark, roastDate: threeDaysAgo)
        let content = TerminalContent.beanContext(bean: bean)
        #expect(content.lines[1] == "3 days off roast.")
    }

    @Test("zero day roast age displayed correctly")
    func zeroDayRoastAgeDisplayed() {
        let bean = Bean(name: "Test", roastDate: Date.now)
        let content = TerminalContent.beanContext(bean: bean)
        #expect(content.lines[1] == "0 days off roast.")
    }
}

@Suite("Terminal Content Character Delay Tests")
struct TerminalContentCharacterDelayTests {

    @Test("onboarding delay is slower than bean context")
    func onboardingSlowerThanBeanContext() {
        let onboarding = TerminalContent.onboarding(hasBeans: false)
        let beanContext = TerminalContent.beanContext(bean: Bean(name: "Test"))

        #expect(onboarding.characterDelay > beanContext.characterDelay)
    }

    @Test("delays are positive values")
    func delaysArePositive() {
        let onboarding = TerminalContent.onboarding(hasBeans: false)
        let beanContext = TerminalContent.beanContext(bean: Bean(name: "Test"))

        #expect(onboarding.characterDelay > 0)
        #expect(beanContext.characterDelay > 0)
    }

    @Test("delays are reasonable for animation")
    func delaysAreReasonable() {
        let onboarding = TerminalContent.onboarding(hasBeans: false)
        let beanContext = TerminalContent.beanContext(bean: Bean(name: "Test"))

        #expect(onboarding.characterDelay < 0.2)
        #expect(beanContext.characterDelay < 0.2)
    }
}
