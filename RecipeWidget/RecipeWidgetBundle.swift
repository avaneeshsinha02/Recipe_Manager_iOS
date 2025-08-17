import WidgetKit
import SwiftUI

struct RecipeWidgetBundle: WidgetBundle {
    var body: some Widget {
        RecipeWidget()
        RecipeWidgetControl()
        RecipeWidgetLiveActivity()
    }
}
