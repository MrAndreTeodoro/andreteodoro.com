# Clear existing data in reverse order of dependencies
puts "Clearing existing data..."
[ BlogPost, Project, GearItem, Book, SportActivity, SocialLink, User ].each(&:destroy_all)

puts "Creating admin user..."
# Create admin user
# Default password: "password" (change this after first login!)
admin = User.create!(
  email_address: "admin@example.com",
  password: "password",
  password_confirmation: "password"
)
puts "✅ Admin user created: admin@example.com / password"

puts "Seeding social links..."
# Social Links
SocialLink.create!([
  { platform: 'twitter', url: 'https://twitter.com/andreteodoro', follower_count: 5400, username: '@andreteodoro', display_in_header: true },
  { platform: 'github', url: 'https://github.com/andreteodoro', follower_count: 1200, username: 'andreteodoro', display_in_header: true },
  { platform: 'linkedin', url: 'https://linkedin.com/in/andreteodoro', follower_count: 3500, username: 'Andre Teodoro', display_in_header: true }
])

puts "Seeding sport activities - Crossfit..."
# Sport Activities - Crossfit
SportActivity.create!([
  # Benchmarks
  { sport_type: 'crossfit', category: 'benchmark', title: 'Fran', value: '4:32', unit: 'minutes', description: '21-15-9 Thrusters (95lbs) and Pull-ups' },
  { sport_type: 'crossfit', category: 'benchmark', title: 'Back Squat 1RM', value: '315', unit: 'lbs', description: 'One rep max back squat' },
  { sport_type: 'crossfit', category: 'benchmark', title: 'Deadlift 1RM', value: '405', unit: 'lbs', description: 'One rep max deadlift' },
  { sport_type: 'crossfit', category: 'benchmark', title: 'Clean & Jerk 1RM', value: '275', unit: 'lbs', description: 'One rep max clean and jerk' },
  { sport_type: 'crossfit', category: 'benchmark', title: 'Snatch 1RM', value: '225', unit: 'lbs', description: 'One rep max snatch' },

  # Results
  { sport_type: 'crossfit', category: 'result', title: 'Open 24.1', value: '245', unit: 'reps', date: Date.new(2025, 2, 29), personal_record: true, description: 'CrossFit Open workout 24.1' },
  { sport_type: 'crossfit', category: 'result', title: 'Murph', value: '43:21', unit: 'minutes', date: Date.new(2025, 5, 27), description: 'Memorial Day Murph - 1 mile run, 100 pull-ups, 200 push-ups, 300 squats, 1 mile run' },
  { sport_type: 'crossfit', category: 'result', title: 'Grace', value: '3:15', unit: 'minutes', date: Date.new(2025, 3, 15), personal_record: true, description: '30 Clean & Jerks for time (135lbs)' },
  { sport_type: 'crossfit', category: 'result', title: 'Diane', value: '5:48', unit: 'minutes', date: Date.new(2025, 4, 10), description: '21-15-9 Deadlifts (225lbs) and Handstand Push-ups' },

  # Events
  { sport_type: 'crossfit', category: 'event', title: 'Local Throwdown', event_name: 'City CrossFit Competition', location: 'Local Box', date: Date.new(2025, 6, 15), description: 'Local competition with 4 WODs' },
  { sport_type: 'crossfit', category: 'event', title: 'Granite Games', event_name: 'Granite Games Scaled Division', location: 'Minneapolis, MN', date: Date.new(2025, 7, 20), description: 'Regional competition' }
])

puts "Seeding sport activities - Hyrox..."
# Sport Activities - Hyrox
SportActivity.create!([
  # Benchmarks
  { sport_type: 'hyrox', category: 'benchmark', title: 'Best Time', value: '1:24:35', unit: 'hours', description: 'Personal best Hyrox finish time (Men Individual)' },
  { sport_type: 'hyrox', category: 'benchmark', title: 'SkiErg 1000m', value: '3:42', unit: 'minutes', description: 'SkiErg benchmark time' },
  { sport_type: 'hyrox', category: 'benchmark', title: 'Rowing 1000m', value: '3:28', unit: 'minutes', description: 'Rowing benchmark time' },
  { sport_type: 'hyrox', category: 'benchmark', title: 'Sled Push', value: '2:15', unit: 'minutes', description: '50m Sled Push (152kg)' },

  # Results
  { sport_type: 'hyrox', category: 'result', title: 'Hyrox Chicago', value: '1:28:12', unit: 'hours', date: Date.new(2025, 11, 10), personal_record: false, location: 'Chicago, IL', description: 'First Hyrox race - finished strong!' },
  { sport_type: 'hyrox', category: 'result', title: 'Hyrox Dallas', value: '1:26:45', unit: 'hours', date: Date.new(2025, 9, 15), personal_record: true, location: 'Dallas, TX', description: 'New PR! Improved pacing strategy' },

  # Events
  { sport_type: 'hyrox', category: 'event', title: 'Hyrox World Championships', event_name: 'Hyrox World Championships', location: 'Nice, France', date: Date.new(2025, 5, 24), description: 'Qualified for World Championships!' },
  { sport_type: 'hyrox', category: 'event', title: 'Hyrox Boston', event_name: 'Hyrox Boston', location: 'Boston, MA', date: Date.new(2025, 3, 8), description: 'Training race before Worlds' }
])

puts "Seeding sport activities - Running..."
# Sport Activities - Running
SportActivity.create!([
  # Benchmarks
  { sport_type: 'running', category: 'benchmark', title: '5K PR', value: '21:34', unit: 'minutes', description: 'Personal record 5K time' },
  { sport_type: 'running', category: 'benchmark', title: '10K PR', value: '45:22', unit: 'minutes', description: 'Personal record 10K time' },
  { sport_type: 'running', category: 'benchmark', title: 'Half Marathon PR', value: '1:42:18', unit: 'hours', description: 'Personal record half marathon' },
  { sport_type: 'running', category: 'benchmark', title: 'Marathon PR', value: '3:35:42', unit: 'hours', description: 'Personal record marathon' },
  { sport_type: 'running', category: 'benchmark', title: 'Mile PR', value: '6:15', unit: 'minutes', description: 'Personal record mile time' },

  # Results
  { sport_type: 'running', category: 'result', title: 'Chicago Marathon', value: '3:42:15', unit: 'hours', date: Date.new(2025, 10, 13), location: 'Chicago, IL', description: 'Great weather, tough race. Learned a lot!' },
  { sport_type: 'running', category: 'result', title: 'Turkey Trot 5K', value: '22:05', unit: 'minutes', date: Date.new(2025, 11, 28), description: 'Post-Thanksgiving fun run' },
  { sport_type: 'running', category: 'result', title: 'Rock \'n\' Roll Half Marathon', value: '1:45:30', unit: 'hours', date: Date.new(2025, 8, 20), location: 'San Diego, CA', description: 'Hot day but finished strong' },
  { sport_type: 'running', category: 'result', title: 'Parkrun 5K', value: '21:58', unit: 'minutes', date: Date.new(2025, 12, 7), description: 'Saturday morning run with the crew' },

  # Events
  { sport_type: 'running', category: 'event', title: 'Boston Marathon', event_name: 'Boston Marathon', location: 'Boston, MA', date: Date.new(2025, 4, 21), description: 'Qualified! BQ-5 minutes. Dream race!' },
  { sport_type: 'running', category: 'event', title: 'NYC Marathon', event_name: 'TCS New York City Marathon', location: 'New York, NY', date: Date.new(2025, 11, 2), description: 'Running the 5 boroughs' },
  { sport_type: 'running', category: 'event', title: 'Austin Half Marathon', event_name: 'Austin Half Marathon', location: 'Austin, TX', date: Date.new(2025, 2, 16), description: 'Training race for Boston' }
])

puts "Seeding books..."
# Books
Book.create!([
  {
    title: 'Atomic Habits',
    author: 'James Clear',
    rating: 5,
    category: 'self-help',
    review: 'An incredibly practical guide to building good habits and breaking bad ones. The 1% improvement philosophy is transformative. Clear provides a framework that actually works - I\'ve used it to build my morning workout routine and it stuck. The concept of habit stacking and environment design are game-changers.',
    notes: 'Key takeaway: Focus on systems, not goals. Make it obvious, attractive, easy, and satisfying. Identity-based habits > outcome-based habits. "You do not rise to the level of your goals. You fall to the level of your systems."',
    read_date: Date.new(2025, 1, 15),
    featured: true,
    isbn: '9780735211292',
    affiliate_link: 'https://amazon.com/atomic-habits'
  },
  {
    title: 'The Pragmatic Programmer',
    author: 'David Thomas, Andrew Hunt',
    rating: 5,
    category: 'tech',
    review: 'A must-read for any software developer. Timeless advice on craftsmanship and professional development. Even after 20+ years, this book remains relevant. The principles taught here have shaped how I approach every project.',
    notes: 'DRY principle, orthogonality, tracer bullets, prototyping techniques. "Don\'t Live with Broken Windows" is my mantra. Invest regularly in your knowledge portfolio.',
    read_date: Date.new(2025, 3, 10),
    featured: true,
    isbn: '9780135957059',
    affiliate_link: 'https://amazon.com/pragmatic-programmer'
  },
  {
    title: 'Deep Work',
    author: 'Cal Newport',
    rating: 4,
    category: 'productivity',
    review: 'Excellent framework for focusing on meaningful work in a distracted world. Newport makes a compelling case for why deep work is becoming increasingly rare and valuable. Some parts feel a bit repetitive, but the core message is solid.',
    notes: 'Schedule deep work blocks. Embrace boredom. Quit social media (or be intentional). Work deeply, then recover completely. "Efforts to deepen your focus will struggle if you don\'t simultaneously wean your mind from a dependence on distraction."',
    read_date: Date.new(2025, 2, 20),
    featured: false,
    isbn: '9781455586691',
    affiliate_link: 'https://amazon.com/deep-work'
  },
  {
    title: 'Endure',
    author: 'Alex Hutchinson',
    rating: 5,
    category: 'fitness',
    review: 'Mind-blowing book about the science of endurance. Hutchinson explores the limits of human performance and what really holds us back (spoiler: it\'s often mental, not physical). Changed how I approach long races.',
    notes: 'The brain acts as a "central governor" protecting us from ourselves. Training is about teaching your brain to allow more suffering. Perception of effort matters more than objective measures. Mental training is as important as physical.',
    read_date: Date.new(2025, 6, 5),
    featured: true,
    isbn: '9780062499981',
    affiliate_link: 'https://amazon.com/endure'
  },
  {
    title: 'Can\'t Hurt Me',
    author: 'David Goggins',
    rating: 4,
    category: 'fitness',
    review: 'Intense and motivational. Goggins\' story is incredible - from overweight to Navy SEAL to ultra-endurance athlete. The "callous your mind" philosophy is powerful, though sometimes extreme. Great for when you need a kick in the pants.',
    notes: 'The 40% rule: when you think you\'re done, you\'re only 40% done. Build your "cookie jar" of past wins. Embrace suffering as growth. "The only way to grow is to get outside your comfort zone and stay there."',
    read_date: Date.new(2025, 4, 12),
    featured: false,
    isbn: '9781544512273',
    affiliate_link: 'https://amazon.com/cant-hurt-me'
  },
  {
    title: 'Shape Up',
    author: 'Ryan Singer',
    rating: 5,
    category: 'tech',
    review: 'The Basecamp approach to product development. 6-week cycles, appetite-based planning, and no backlogs. Revolutionary way to think about shipping software. We\'ve adopted many of these practices in our team.',
    notes: 'Shape work before giving it to teams. 6-week cycles with 2-week cooldowns. Bet on projects, don\'t maintain backlogs. "When people ask why something costs so much, we can point to what we\'re not doing."',
    read_date: Date.new(2025, 7, 18),
    featured: true,
    isbn: '9780578650203',
    affiliate_link: 'https://basecamp.com/shapeup'
  }
])

puts "Seeding gear items..."
# Gear Items
GearItem.create!([
  # Tech
  {
    name: 'MacBook Pro 16" M3 Max',
    description: 'My primary development machine. Incredible performance for coding, running multiple Docker containers, and even video editing. The battery life is unreal - easily get through a full workday. The display is gorgeous for long coding sessions.',
    category: 'tech',
    price: 3499.00,
    featured: true,
    position: 1,
    affiliate_link: 'https://amazon.com/macbook-pro'
  },
  {
    name: 'LG UltraWide 38" Monitor',
    description: 'Perfect for development work. Replaces my dual monitor setup. The 3840x1600 resolution gives me tons of space for code, terminal, and docs all at once. Highly recommend for any developer.',
    category: 'tech',
    price: 1299.99,
    featured: true,
    position: 2,
    affiliate_link: 'https://amazon.com/lg-ultrawide'
  },
  {
    name: 'Keychron Q6 Pro',
    description: 'Full-size mechanical keyboard with QMK/VIA support. Hotswappable switches, gasket mount, and amazing build quality. Currently running Gateron Oil Kings - buttery smooth typing experience.',
    category: 'tech',
    price: 219.00,
    featured: true,
    position: 3,
    affiliate_link: 'https://amazon.com/keychron-q6'
  },
  {
    name: 'Logitech MX Master 3S',
    description: 'Best mouse I\'ve ever used. The horizontal scroll wheel is a game-changer for coding. Silent clicks are great for shared workspaces. Multi-device switching is seamless.',
    category: 'tech',
    price: 99.99,
    featured: false,
    position: 4,
    affiliate_link: 'https://amazon.com/mx-master-3s'
  },

  # Fitness
  {
    name: 'Rogue Echo Bike',
    description: 'The best air bike for CrossFit workouts. Built like a tank - this thing will outlast you. Perfect for high-intensity intervals. The fan resistance is smooth and consistent.',
    category: 'fitness',
    price: 895.00,
    featured: true,
    position: 5,
    affiliate_link: 'https://rogueeurope.eu/rogue-echo-bike'
  },
  {
    name: 'Nike Metcon 9',
    description: 'My go-to CrossFit shoe. Great stability for lifting, comfortable for runs up to 5K, and durable enough to withstand rope climbs. The React foam makes box jumps easier on the joints.',
    category: 'fitness',
    price: 150.00,
    featured: true,
    position: 6,
    affiliate_link: 'https://amazon.com/nike-metcon-9'
  },
  {
    name: 'Garmin Forerunner 965',
    description: 'Best running watch on the market. Training metrics are incredibly detailed - VO2 max, training load, recovery time, etc. The AMOLED display is beautiful. Battery lasts 2+ weeks with daily workouts.',
    category: 'fitness',
    price: 599.99,
    featured: true,
    position: 7,
    affiliate_link: 'https://amazon.com/garmin-forerunner-965'
  },
  {
    name: 'Rogue Ohio Power Bar',
    description: 'Excellent all-purpose barbell. The knurling is aggressive enough for heavy deadlifts but won\'t tear up your hands. 45lb, 28.5mm diameter. Made in the USA.',
    category: 'fitness',
    price: 325.00,
    featured: false,
    position: 8,
    affiliate_link: 'https://rogueeurope.eu/ohio-power-bar'
  },
  {
    name: 'Concept2 RowErg',
    description: 'The gold standard for rowing machines. Used in Hyrox races and CrossFit gyms worldwide. Smooth, quiet, and incredibly durable. The PM5 monitor tracks every metric you could want.',
    category: 'fitness',
    price: 1015.00,
    featured: true,
    position: 9,
    affiliate_link: 'https://amazon.com/concept2-rower'
  },

  # Everyday
  {
    name: 'AirPods Pro 2',
    description: 'Perfect for coding sessions and workouts. Noise cancellation is a game changer in open offices. Transparency mode is great for gym safety. USB-C charging finally!',
    category: 'everyday',
    price: 249.00,
    featured: true,
    position: 10,
    affiliate_link: 'https://amazon.com/airpods-pro-2'
  },
  {
    name: 'WHOOP 4.0',
    description: 'Recovery tracking band. Helps me balance training load and recovery. Sleep tracking is incredibly accurate. The strain and recovery scores guide my training decisions.',
    category: 'everyday',
    price: 239.00,
    featured: false,
    position: 11,
    affiliate_link: 'https://join.whoop.com'
  },
  {
    name: 'Yeti Rambler 26oz',
    description: 'Best water bottle for the gym. Keeps water ice cold for hours. The straw cap is perfect for quick sips during WODs. Dishwasher safe and incredibly durable.',
    category: 'everyday',
    price: 45.00,
    featured: false,
    position: 12,
    affiliate_link: 'https://amazon.com/yeti-rambler'
  }
])

puts "Seeding projects..."
# Startups
Project.create!([
  {
    name: 'FitTrack Pro',
    description: 'A comprehensive fitness tracking platform built for CrossFit athletes and endurance runners. Track workouts, analyze performance metrics, and connect with your training community. Features include workout logging, PR tracking, and detailed analytics.',
    url: 'https://fittrackpro.com',
    project_type: 'startup',
    featured: true,
    status: 'active',
    position: 1,
    tech_stack: [ 'Rails 8', 'Turbo', 'Stimulus', 'Tailwind CSS', 'PostgreSQL' ].to_json
  },
  {
    name: 'DevFlow',
    description: 'A developer productivity tool that helps you track time, manage projects, and analyze your coding patterns. Built for indie hackers and small teams who want to ship faster without complex project management overhead.',
    url: 'https://devflow.app',
    project_type: 'startup',
    featured: true,
    status: 'in_development',
    position: 2,
    tech_stack: [ 'Next.js', 'TypeScript', 'Prisma', 'tRPC', 'Tailwind CSS' ].to_json
  },
  {
    name: 'ReadWise Clone',
    description: 'Personal reading tracking and note-taking app. Sync your Kindle highlights, write reviews, and build your digital library. Export your notes and insights to Notion, Obsidian, or Markdown.',
    url: 'https://myreads.io',
    project_type: 'startup',
    featured: true,
    status: 'active',
    position: 3,
    tech_stack: [ 'Rails', 'Hotwire', 'ViewComponent', 'Tailwind CSS' ].to_json
  }
])

# Side Projects
side_project_data = [
  { name: 'RaceDay', description: 'Simple race countdown timer for runners', url: 'https://github.com/andreteodoro/raceday' },
  { name: 'WOD Generator', description: 'Random CrossFit workout generator', url: 'https://github.com/andreteodoro/wod-gen' },
  { name: 'PR Tracker', description: 'Personal record tracking for lifts', url: 'https://github.com/andreteodoro/pr-tracker' },
  { name: 'BookNotes', description: 'Minimalist book notes app', url: 'https://github.com/andreteodoro/booknotes' },
  { name: 'StravaViz', description: 'Strava data visualizer', url: 'https://github.com/andreteodoro/stravaviz' },
  { name: 'TailwindStarter', description: 'My Rails + Tailwind boilerplate', url: 'https://github.com/andreteodoro/rails-tw-starter' },
  { name: 'DevQuotes', description: 'Inspirational quotes API for developers', url: 'https://github.com/andreteodoro/devquotes' },
  { name: 'GymTimer', description: 'HIIT interval timer PWA', url: 'https://github.com/andreteodoro/gym-timer' },
  { name: 'CodeSnippets', description: 'Personal code snippet manager', url: 'https://github.com/andreteodoro/snippets' },
  { name: 'HabitStack', description: 'Habit tracking app based on Atomic Habits', url: 'https://github.com/andreteodoro/habitstack' },
  { name: 'RunningLog', description: 'Minimal running log CLI tool', url: 'https://github.com/andreteodoro/runlog' },
  { name: 'AffiliateDash', description: 'Dashboard for tracking affiliate links', url: 'https://github.com/andreteodoro/affiliate-dash' }
]

side_project_data.each_with_index do |data, index|
  Project.create!(
    name: data[:name],
    description: data[:description],
    project_type: 'side_project',
    status: 'active',
    position: index + 1,
    url: data[:url]
  )
end

puts "Seeding blog posts..."
# Blog Posts
BlogPost.create!([
  {
    title: 'Building a Rails 8 Portfolio with Hotwire',
    slug: 'rails-8-portfolio-hotwire',
    excerpt: 'How I built my personal portfolio site using Rails 8, Turbo, and Tailwind CSS. No complex JavaScript frameworks needed - just the power of Hotwire.',
    content: 'Full blog post content here... Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    published_at: DateTime.new(2025, 11, 15, 10, 0, 0),
    viral: false,
    featured: true,
    views_count: 1250
  },
  {
    title: 'My First Marathon: Lessons from Chicago',
    slug: 'first-marathon-chicago',
    excerpt: 'I ran my first marathon in Chicago and learned some hard lessons about pacing, nutrition, and mental toughness. Here\'s what I wish I knew before race day.',
    content: 'Full blog post content here... Training for a marathon is one thing, but racing 26.2 miles is a completely different beast.',
    published_at: DateTime.new(2025, 10, 20, 14, 30, 0),
    viral: true,
    featured: true,
    views_count: 3420
  },
  {
    title: 'The 40% Rule: What David Goggins Taught Me About Training',
    slug: '40-percent-rule-goggins',
    excerpt: 'When you think you\'re done, you\'re only 40% done. How applying Goggins\' philosophy transformed my approach to hard workouts.',
    content: 'Full blog post content here... The concept is simple but brutal: when your mind tells you that you\'re done, you\'re really only 40% of the way to your actual limit.',
    published_at: DateTime.new(2025, 9, 5, 9, 15, 0),
    viral: false,
    featured: false,
    views_count: 856
  },
  {
    title: 'From Zero to Boston Qualifier: My Running Journey',
    slug: 'zero-to-boston-qualifier',
    excerpt: 'Three years ago I couldn\'t run a mile. Last week I qualified for the Boston Marathon. Here\'s how I went from couch to BQ.',
    content: 'Full blog post content here... My running journey started with a simple challenge from a friend. I couldn\'t even run a mile without stopping.',
    published_at: DateTime.new(2025, 8, 12, 16, 45, 0),
    viral: true,
    featured: true,
    views_count: 5240
  },
  {
    title: 'CrossFit vs Hyrox: Which One Should You Try?',
    slug: 'crossfit-vs-hyrox',
    excerpt: 'Both are challenging, both will make you fitter, but they\'re quite different. Here\'s my comparison after doing both for a year.',
    content: 'Full blog post content here... CrossFit focuses on varied functional movements performed at high intensity. Hyrox is a standardized fitness race combining running and functional exercises.',
    published_at: DateTime.new(2025, 7, 8, 11, 20, 0),
    viral: false,
    featured: false,
    views_count: 1890
  },
  {
    title: 'Building in Public: Why I Share Everything',
    slug: 'building-in-public',
    excerpt: 'Sharing my projects, metrics, and failures publicly has been one of the best decisions I\'ve made as an indie developer. Here\'s why you should too.',
    content: 'Full blog post content here... Building in public means sharing your journey transparently - the good, the bad, and the ugly.',
    published_at: DateTime.new(2025, 6, 22, 13, 0, 0),
    viral: true,
    featured: true,
    views_count: 4120
  }
])

puts "\n" + "="*50
puts "✅ Seeding completed successfully!"
puts "="*50
puts "📊 Final counts:"
puts "   - Social Links: #{SocialLink.count}"
puts "   - Sport Activities: #{SportActivity.count}"
puts "     • Crossfit: #{SportActivity.crossfit.count}"
puts "     • Hyrox: #{SportActivity.hyrox.count}"
puts "     • Running: #{SportActivity.running.count}"
puts "   - Books: #{Book.count}"
puts "   - Gear Items: #{GearItem.count}"
puts "   - Projects: #{Project.count}"
puts "     • Startups: #{Project.startups.count}"
puts "     • Side Projects: #{Project.side_projects.count}"
puts "   - Blog Posts: #{BlogPost.count}"
puts "="*50
